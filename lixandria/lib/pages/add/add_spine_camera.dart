/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: add_spine_camera.dart
Description: UI Page. Handles the camera and relevant business logic.
First Written On: 12/06/2023
Last Edited On:  04/07/2023
 */

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lixandria/pages/add/add_spine.dart';

class AddSpineCamera extends StatefulWidget {
  final String? ipAddress;
  const AddSpineCamera({Key? key, this.ipAddress}) : super(key: key);

  @override
  State<AddSpineCamera> createState() => _AddSpineCameraState();
}

class _AddSpineCameraState extends State<AddSpineCamera> {
  CameraController? controller;
  List<CameraDescription>? cameraList;
  String imagePath = "";

  @override
  void initState() {
    initCamera();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return Container();
    }

    var controllerAspect = controller?.value.aspectRatio ?? 1;
    final scale =
        1 / (controllerAspect * MediaQuery.of(context).size.aspectRatio);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // * Camera
            if (controller != null)
              ClipRect(
                clipper: _MediaSizeClipper(MediaQuery.of(context).size),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: CameraPreview(controller!),
                ),
              ),

            // * Capture Image Button
            if (controller != null)
              Container(
                padding: const EdgeInsets.all(0.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: IconButton(
                    icon: const Icon(
                      Icons.camera,
                      size: 50,
                    ),
                    onPressed: () async {
                      try {
                        final image = await controller!.takePicture();
                        setState(() {
                          imagePath = image.path;
                        });
                        if (context.mounted) {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (context) => SpineAdd(
                                        imagePath: imagePath,
                                        ipAddress: widget.ipAddress!,
                                      )));
                          // await controller!.dispose();
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "An error has occurred: ${e.toString()}")));
                      }
                    }),
              )
          ],
        ),
      ),
    );
  }

  initCamera() async {
    // If cameraList == null shorthand
    cameraList ??= await availableCameras();

    if (controller?.value.isInitialized ?? false) {
      controller!.dispose();
    }

    controller = CameraController(
        cameraList!.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.back,
        ),
        ResolutionPreset.max,
        enableAudio: false);
    controller!.initialize().then((value) {
      setState(() {});
    });
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
