from flask import Flask

# Application Initialisation
app = Flask(__name__)


@app.route("/Lixandria_API")
def SpineOCR():
    # Receive and Read Image
    # shelf_image = request.files.get("image")
    # image_buffer = np.fromfile(shelf_image, np.uint8)
    # img = cv2.imdecode(image_buffer, flags=cv2.IMREAD_COLOR)

    # print(img.shape)

    return "<p>Hello, World!</p>"

# Run the API
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
