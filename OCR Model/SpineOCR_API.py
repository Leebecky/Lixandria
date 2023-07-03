from flask import Flask, request, jsonify
from waitress import serve
from imutils.object_detection import non_max_suppression
import cv2
import numpy as np
import base64
import json
import math
from paddleocr import PaddleOCR

# Application Initialisation
app = Flask(__name__)
east_model_path = "east_text_detection.pb"

# Spine Segmentation & OCR Functions
def preprocessing(img):
    # resize image
    img_resized = resizeImage(img, scale=25)

    # Convert to grayscale
    img_gray = cv2.cvtColor(img_resized, cv2.COLOR_RGB2GRAY)

    return img_resized, img_gray


def resizeImage(img, scale):
    width = int(img.shape[1] * scale / 100)
    height = int(img.shape[0] * scale / 100)
    dim = (width, height)

    img_resized = cv2.resize(img, dim, interpolation=cv2.INTER_AREA)
    return img_resized


def cannyEdge(img):
    blur = cv2.GaussianBlur(img, (5, 5), 0.5)
    edge_image = cv2.Canny(blur, 150, 250, apertureSize=3)

    return edge_image


def get_hough_lines(img, ori):
    lines = cv2.HoughLines(image=img,
                           rho=.75,
                           theta=np.pi / 360,
                           threshold=150,
                           lines=None,
                           srn=0,
                           stn=0,
                           min_theta=45 * (np.pi / 180),
                           max_theta=225 * (np.pi / 180))
    return lines


def get_hough_coords(hough_lines):
    # Convert hough lines into coordinates
    hough_points = []
    if hough_lines is not None:
        for i in range(0, len(hough_lines)):
            rho = hough_lines[i][0][0]
            theta = hough_lines[i][0][1]
            a = math.cos(theta)
            b = math.sin(theta)
            x0 = a * rho
            y0 = b * rho
            pt1 = (int(x0 + 1000 * (-b)), int(y0 + 1000 * (a)))
            pt2 = (int(x0 - 1000 * (-b)), int(y0 - 1000 * (a)))
            hough_points.append([pt1, pt2])
    return hough_points


def sort_hough_lines(img, hough_coords):
    # Sort the set of hough lines from top to bottom
    y_sort = []
    y_intersect = []

    # For each set of hough lines, calculate the straight line equation and determine the y-value at the edges of the image
    for i in range(0, len(hough_coords)):
        x1 = hough_coords[i][0][0]
        x2 = hough_coords[i][1][0]
        y1 = hough_coords[i][0][1]
        y2 = hough_coords[i][1][1]

        denom = 1 if (x2 - x1) == 0 else (x2 - x1)
        m = (y2 - y1) / denom

        # Straight Line Equation: y = mx + c
        c = y1 - (m * x1)

        # Determine y at midpoint
        y_point = (m * int(img.shape[1] / 2)) + c
        y2 = (m * int(img.shape[1])) + c
        y_sort.append(y_point)
        y_intersect.append({"y1": int(c), "y2": int(y2)})

    sort_index = np.argsort(y_sort)
    sorted = np.array(hough_coords)[sort_index]
    sort_y = np.array(y_sort)[sort_index]
    sort_intersect = np.array(y_intersect)[sort_index]
    return sorted, sort_y, sort_intersect


def east(img, resize=(640, 640)):
    # East Text Detector. Code referenced from (Rosebrock, 2018): https://pyimagesearch.com/2018/08/20/opencv-text-detection-east-text-detector/

    (origH, origW) = img.shape[:2]
    (newW, newH) = resize
    rW = origW / float(newW)
    rH = origH / float(newH)
    resized = cv2.resize(img, (newW, newH))
    (H, W) = resized.shape[:2]

    # construct a blob from the image to forward pass it to EAST model
    blob = cv2.dnn.blobFromImage(resized,
                                 1.0, (W, H), (123.68, 116.78, 103.94),
                                 swapRB=True,
                                 crop=False)

    # load the pre-trained EAST model for text detection
    net = cv2.dnn.readNet(east_model_path)

    # The following two layer need to pulled from EAST model for achieving this.
    layerNames = ["feature_fusion/Conv_7/Sigmoid", "feature_fusion/concat_3"]

    #Forward pass the blob from the image to get the desired output layers
    net.setInput(blob)
    (scores, geometry) = net.forward(layerNames)

    # Find predictions and  apply non-maxima suppression
    (boxes, confidence_val) = predictions(scores, geometry)
    boxes = non_max_suppression(np.array(boxes), probs=confidence_val)
    results = []

    # loop over the bounding boxes to find the coordinate of bounding boxes
    for idx, (startX, startY, endX, endY) in enumerate(boxes):
        # scale the coordinates based on the respective ratios in order to reflect bounding box on the original image
        startX = int(startX * rW)
        startY = int(startY * rH)
        endX = int(endX * rW)
        endY = int(endY * rH)

        #save the regions of interest
        results.append(((startX, startY, endX, endY, idx)))

    return results


def predictions(prob_score, geo):
    # Returns a bounding box and probability score if it is more than minimum confidence
    # Code referenced from (Rosebrock, 2018): https://pyimagesearch.com/2018/08/20/opencv-text-detection-east-text-detector/

    (numR, numC) = prob_score.shape[2:4]
    boxes = []
    confidence_val = []

    # loop over rows
    for y in range(0, numR):
        scoresData = prob_score[0, 0, y]
        x0 = geo[0, 0, y]
        x1 = geo[0, 1, y]
        x2 = geo[0, 2, y]
        x3 = geo[0, 3, y]
        anglesData = geo[0, 4, y]

        # loop over the number of columns
        for i in range(0, numC):
            if scoresData[i] < 0.5:
                continue

            (offX, offY) = (i * 4.0, y * 4.0)

            # extracting the rotation angle for the prediction and computing the sine and cosine
            angle = anglesData[i]
            cos = np.cos(angle)
            sin = np.sin(angle)

            # using the geo volume to get the dimensions of the bounding box
            h = x0[i] + x2[i]
            w = x1[i] + x3[i]

            # compute start and end for the text pred bbox
            endX = int(offX + (cos * x1[i]) + (sin * x2[i]))
            endY = int(offY - (sin * x1[i]) + (cos * x2[i]))
            startX = int(endX - w)
            startY = int(endY - h)

            boxes.append((startX, startY, endX, endY))
            confidence_val.append(scoresData[i])

    # return bounding boxes and associated confidence_val
    return (boxes, confidence_val)


def east_meets_hough(east, coords, img):
    # Sort Hough Coordinates
    sorted_coords, sorted_y, sorted_intersect = sort_hough_lines(img, coords)
    book_spine_set = []
    partial_segment = []

    # Identify spine boundaries based on hough lines and detected text
    for i in range(0, len(sorted_coords)):
        if (i == 0):  # Line 0 as bottom line
            get_spine_boundaries(east, img, sorted_y, book_spine_set, -1,
                                 partial_segment, sorted_intersect)

        get_spine_boundaries(east, img, sorted_y, book_spine_set, i,
                             partial_segment, sorted_intersect)

    for i in range(0, len(partial_segment)):
        coord_index = partial_segment[i]["index"]
        bottom_target = partial_segment[i]["bottom_target"]

        top_left = partial_segment[i]["top_left"]
        top_right = partial_segment[i]["top_right"]
        bottom_left = partial_segment[i]["bottom_left"]
        bottom_right = partial_segment[i]["bottom_right"]

        for idx in range(coord_index + 1, len(sorted_y)):
            bottom_line = int(sorted_y[idx])
            isWithinBottom = bottom_target < bottom_line

            if (isWithinBottom):
                if ((top_left, top_right, bottom_right, bottom_left)
                        not in book_spine_set):

                    book_spine_set.append(
                        (top_left, top_right, bottom_right, bottom_left))
    return book_spine_set


def get_spine_boundaries(east, img, sorted_y, book_spine_set, i,
                         partial_segment, sorted_intersect):

    # Determine if text box within boundaries
    # yBottom < yBox < yTop
    y_top = 0 if i == -1 else int(sorted_y[i])
    y_bottom = sorted_y[0] if i == -1 else img.shape[0] if i == (
        len(sorted_y) - 1) else int(sorted_y[i + 1])

    # y-intersect Calculation
    int_top_left = 0 if i == -1 else sorted_intersect[i]["y1"]
    int_top_right = 0 if i == -1 else sorted_intersect[i]["y2"]
    int_bottom_left = sorted_intersect[0]["y1"] if i == -1 else img.shape[
        1] if i == (len(sorted_intersect) - 1) else sorted_intersect[i +
                                                                     1]["y1"]
    int_bottom_right = sorted_intersect[0]["y2"] if i == -1 else img.shape[
        1] if i == (len(sorted_intersect) - 1) else sorted_intersect[i +
                                                                     1]["y2"]

    for ((start_X, start_Y, end_X, end_Y, idx)) in east:

        #? Given the top left and bottom right coordinates of text, determine if yTextTop < yTop and yTextBottom > yBottom
        # ? If yTextTop < yTop and yTextBottom !> yBottom, consider neighbouring sets, and vice versa
        isWithinTop = start_Y > y_top
        isWithinBottom = end_Y < y_bottom
        isOverBottom = start_Y < y_bottom

        if (isWithinTop and isOverBottom):
            is_recorded = False
            if (len(partial_segment) > 0):
                is_recorded = any(elm["top_value"] == int(y_top)
                                  for elm in partial_segment)
            if (not is_recorded):
                partial_segment.append({
                    "top_value": int(y_top),
                    "bottom_target": end_Y,
                    "top_left": int_top_left,
                    "top_right": int_top_right,
                    "bottom_left": int_bottom_left,
                    "bottom_right": int_bottom_right,
                    "index": i
                })

        if (isWithinTop and isWithinBottom):
            if ((int_top_left, int_top_right, int_bottom_right,
                 int_bottom_left) not in book_spine_set):
                book_spine_set.append((int_top_left, int_top_right,
                                       int_bottom_right, int_bottom_left))


def spine_segment(book_spine_set, disp, ocr_reader):

    img_width = disp.shape[1]
    output_set = []

    for x in range(0, len(book_spine_set)):
        spine_coords = book_spine_set[x]

        # Crop image
        mask = np.zeros(disp.shape, dtype=np.uint8)
        pts = np.array([(0, spine_coords[0]), (img_width, spine_coords[1]),
                        (img_width, spine_coords[2]), (0, spine_coords[3])],
                       np.int32)
        cv2.fillPoly(mask, [pts], (255, 255, 255))

        filt_img = disp & mask

        book_spine_segment = filt_img.copy()

        highest_point = spine_coords[
            0] if spine_coords[0] < spine_coords[1] else spine_coords[1]
        lower_point = spine_coords[
            2] if spine_coords[2] > spine_coords[3] else spine_coords[3]

        highest_point = 0 if highest_point < 0 else highest_point
        lower_point = img_width if lower_point > img_width else lower_point

        book_spine_segment = book_spine_segment[highest_point:lower_point, :]

        if (book_spine_segment.shape[0] <= 0 or book_spine_segment.shape[1] <= 0): continue
        book_spine_segment = resizeImage(book_spine_segment, 150)
        results = ocr_reader.ocr(book_spine_segment, cls=True)

        # Encode image to return
        __, img_encode = cv2.imencode(".png", book_spine_segment)
        jpg_as_text = base64.b64encode(img_encode).decode()

        spine_text = evaluate_ocr_output(results)

        if (spine_text != ""):
            # cv2.imshow("Filt",spine_segment)
            # cv2.waitKey()
            # Preparing API Response
            json_data = {'img': jpg_as_text, "spine_text": spine_text}
            with open('./0.json', 'w') as outfile:
                json.dump(json_data, outfile, ensure_ascii=False, indent=4)

            output_set.append(json_data)

    return output_set


def evaluate_ocr_output(ocr):
    [ocr_output] = ocr
    extracted_values = []

    # Extract Top Left Bounding Box and Text
    for i in range(0, len(ocr_output)):
        if (ocr_output[i][1][1] >= 0.8):  # filter low confidence predictions
            extracted_values.append([ocr_output[i][0][0], ocr_output[i][1][0]])

    # Sort by x-axis
    extracted_values.sort()

    # Sort based on y-axis if x-axis values are similar
    for i in range(1, len(extracted_values)):
        prev = extracted_values[i - 1][0]
        current = extracted_values[i][0]

        if (prev[0] > current[0] - 50):
            if (prev[1] > current[1]):
                extracted_values[i - 1], extracted_values[
                    i] = extracted_values[i], extracted_values[i - 1]

    # Extract the sorted spine text
    spine_text = " ".join(text[1] for text in extracted_values)

    return spine_text


# API Code
@app.route("/Lixandria_API", methods=["GET"])
def get():
    return "<p>GET request unavailable 1.3</p>"


@app.route("/Lixandria_API", methods=["POST"])
def SpineOCR():
    try:
        # Receive and Read Image
        shelf_image = request.files.get("image")
        image_buffer = np.fromfile(shelf_image, np.uint8)
        
        img = cv2.imdecode(image_buffer, flags=cv2.IMREAD_COLOR)
        # Process Image

        # Pre Processing:
        img_resized, img_gray = preprocessing(img)

        # Canny Edge Detection
        img_canny = cannyEdge(img_gray)
        cv2.imshow("img", img_canny)
        cv2.waitKey()
        
        # Hough Lines
        disp = img_resized.copy()
        # disp = cv2.rotate(disp, cv2.ROTATE_90_COUNTERCLOCKWISE)
        # img_canny = cv2.rotate(img_canny, cv2.ROTATE_90_COUNTERCLOCKWISE)
        hough_lines = get_hough_lines(img_canny, disp)
        coords = get_hough_coords(hough_lines)
        east_boxes = east(disp)

        # Image Segmentation
        ocr_reader = PaddleOCR(use_angle_cls=True,
                               lang='en',
                               ocr_version="PP-OCRv3")
        # , cls_model_dir="en_PP-OCRv3_rec_train"
        book_spine_set = east_meets_hough(east_boxes, coords, disp)
        api_response = spine_segment(book_spine_set, disp, ocr_reader)

        return jsonify(api_response)
    except Exception as error:
        return jsonify({"status": str(error)})


# Run the API
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
# serve(app, host='0.0.0.0', port=8000, threads=1)  #WAITRESS!
