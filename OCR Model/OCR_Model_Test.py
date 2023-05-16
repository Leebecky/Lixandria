# Import Libraries
import cv2
import numpy as np
import math
from imutils.object_detection import non_max_suppression
from paddleocr import PaddleOCR

east_model_path = "east_text_detection.pb"


def preprocessing(img):
    # resize image
    img_resized = resizeImage(img, scale=50)

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


def sort_hough_lines(img, hough_lines):
    # x_sort = []
    y_sort = []
    y_intersect = []
    # left_x = []
    # right_x = []

    for i in range(0, len(hough_lines)):
        x1 = hough_lines[i][0][0]
        x2 = hough_lines[i][1][0]
        y1 = hough_lines[i][0][1]
        y2 = hough_lines[i][1][1]

        denom = 1 if (x2 - x1) == 0 else (x2 - x1)
        m = (y2 - y1) / denom

        # y = mx + c
        c = y1 - (m * x1)

        # if m != 0:
        # x_point = (int(img.shape[0] / 2) - c) / m
        # left = (int(img.shape[0]) - c) / m if m < 0 else (0 - c) / m
        # right = (0 - c) / m if m < 0 else (int(img.shape[0]) - c) / m

        # x_sort.append(x_point)
        # left_x.append([left, img.shape[0]])
        # right_x.append([right, 0])

        # Determine y at midpoint
        y_point = (m * int(img.shape[1] / 2)) + c
        y2 = (m * int(img.shape[1])) + c
        y_sort.append(y_point)
        y_intersect.append({"y1": int(c), "y2": int(y2)})

    # sort_index = np.argsort(x_sort)
    sort_index = np.argsort(y_sort)
    sorted = np.array(hough_lines)[sort_index]
    sort_y = np.array(y_sort)[sort_index]
    sort_intersect = np.array(y_intersect)[sort_index]
    # sort_left = np.array(left_x)[sort_index]
    # sort_right = np.array(right_x)[sort_index]
    return sorted, sort_y, sort_intersect
    # return sorted, sort_left, sort_right


def get_hough_coords(hough_lines):
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


def draw_hough_lines(img, hough_lines):
    # if hough_lines is not None:
    for i in range(0, len(hough_lines)):
        cv2.line(img, hough_lines[i][0], hough_lines[i][1], (0, 0, 255), 3,
                 cv2.LINE_AA)
    return img

def east(img, resize=(640,640)):
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

        #extract the region of interest
        r = img[startY:endY, startX:endX]
        results.append(((startX, startY, endX, endY, idx)))

    return results


# Returns a bounding box and probability score if it is more than minimum confidence
def predictions(prob_score, geo):
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


def spine_recognition(img):
    print("PreProcess")


def main(file_path):
    # Read Image
    shelf_image = cv2.imread(file_path)

    # Pre Processing:
    img_resized, img_gray = preprocessing(shelf_image)

    # Canny Edge Detection
    img_canny = cannyEdge(img_gray)

    # Hough Lines
    disp = img_resized.copy()
    disp = cv2.rotate(disp, cv2.ROTATE_90_COUNTERCLOCKWISE)
    img_canny = cv2.rotate(img_canny, cv2.ROTATE_90_COUNTERCLOCKWISE)
    hough_lines = get_hough_lines(img_canny, disp)
    coords = get_hough_coords(hough_lines)
    east_boxes = east(disp)

    # Image Segmentation
    ocr_reader = PaddleOCR(use_angle_cls=True, lang='en')

    book_spine_set = east_meets_hough(east_boxes, coords, disp)
    for x in range(0, len(book_spine_set)):
        spine_segment = disp.copy()
        spine_segment = spine_segment[
            book_spine_set[x][0]:book_spine_set[x][1], :]

        spine = cv2.cvtColor(spine_segment, cv2.COLOR_RGB2GRAY)
        results = ocr_reader.ocr(spine_segment, cls=True)

        cv2.imshow("Segment", spine_segment)
        print("OCR: ", results)
        print("OCR: ", results[0][0][0][1])
        cv2.waitKey(0)



def east_meets_hough(east, coords, img):
    # Sort Hough Coordinates
    sorted_coords, sorted_y, sorted_intersect = sort_hough_lines(img, coords)
    book_spine_set = []
    partial_segment = []
    identified_text = []

    for i in range(0, len(sorted_coords)):
        if (i == 0):  # Line 0 as bottom line
            get_spine_boundaries(east, img, sorted_coords, sorted_y,
                                 book_spine_set, -1, partial_segment,
                                 identified_text)

        get_spine_boundaries(east, img, sorted_coords, sorted_y,
                             book_spine_set, i, partial_segment,
                             identified_text)

    for i in range(0, len(partial_segment)):
        new_img = img.copy()
        coord_index = partial_segment[i]["index"]
        top_line = partial_segment[i]["top_value"]
        bottom_target = partial_segment[i]["bottom_target"]

        cv2.line(new_img, (0, top_line), (img.shape[1], top_line), (0, 255, 0),
                 3, cv2.LINE_AA)
        for idx in range(coord_index + 1, len(sorted_y)):
            bottom_line = int(sorted_y[idx])
            isWithinBottom = bottom_target < bottom_line

            relevant_box = [
                x for x in identified_text if x["index"] == coord_index
            ]
            for val in relevant_box:
                start_X = val["start_x"]
                start_Y = val["start_y"]
                end_X = val["end_x"]
                end_Y = val["end_y"]
                cv2.rectangle(new_img, (start_X, start_Y), (end_X, end_Y),
                              (0, 0, 255), 2)

            cv2.line(new_img, (0, bottom_line), (img.shape[1], bottom_line),
                     (255, 255, 0), 3, cv2.LINE_AA)
            if (isWithinBottom):
                cv2.line(new_img, (0, bottom_line),
                         (img.shape[1], bottom_line), (255, 0, 255), 3,
                         cv2.LINE_AA)
                if ((top_line, bottom_line) not in book_spine_set):
                    book_spine_set.append((top_line, bottom_line))
                break

    return book_spine_set


def get_spine_boundaries(east, img, sorted_coords, sorted_y, book_spine_set, i,
                         partial_segment, identified_text):
    x = img.copy()

    # determining top/bottom lines
    top_left = (0, 0) if i == -1 else sorted_coords[i][0]
    top_right = (img.shape[1], 0) if i == -1 else sorted_coords[i][1]
    bottom_left = sorted_coords[0][0] if i == -1 else (
        0, img.shape[0]) if i == (len(sorted_coords) -
                                  1) else sorted_coords[i + 1][0]
    bottom_right = sorted_coords[0][1] if i == -1 else (
        img.shape[1], img.shape[0]) if i == (len(sorted_coords) -
                                             1) else sorted_coords[i + 1][1]
    cv2.line(x, top_left, top_right, (0, 255, 0), 3, cv2.LINE_AA)
    cv2.line(x, bottom_left, bottom_right, (255, 0, 0), 3, cv2.LINE_AA)
    
    # Determine if text box within boundaries
    # yBottom < yBox < yTop
    y_top = 0 if i == -1 else int(sorted_y[i])
    y_bottom = sorted_y[0] if i == -1 else img.shape[0] if i == (
        len(sorted_y) - 1) else int(sorted_y[i + 1])

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
                    "index": i
                })
                identified_text.append({
                    "start_x": start_X,
                    "start_y": start_Y,
                    "end_x": end_X,
                    "end_y": end_Y,
                    "index": i
                })
            
        if (isWithinTop and isWithinBottom):
            if ((int(y_top), int(y_bottom)) not in book_spine_set):
                book_spine_set.append((int(y_top), int(y_bottom)))

            cv2.rectangle(x, (start_X, start_Y), (end_X, end_Y), (0, 0, 255),
                          2)


# Run
# main("Images/upright4.webp")
img_set = ["upright.jpeg"]
#  , "upright2.jpeg", "upright3.jpeg", "upright4.webp"]
# , "sideways.jpeg", "mixed.jpeg"
for file in img_set:
    path = "Images/" + file
    main(path)