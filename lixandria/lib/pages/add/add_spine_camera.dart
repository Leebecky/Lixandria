import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lixandria/pages/add/add_spine.dart';
import '../../main.dart';

class AddSpineCamera extends StatefulWidget {
  final String? ipAddress;
  const AddSpineCamera({Key? key, this.ipAddress}) : super(key: key);
  @override
  _AddSpineCameraState createState() => _AddSpineCameraState();
}

class _AddSpineCameraState extends State<AddSpineCamera> {
  CameraController? controller;
  String imagePath = "";

  @override
  void initState() {
    super.initState();

    controller = CameraController(cameras![0], ResolutionPreset.max);
    controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    final scale = 1 /
        (controller!.value.aspectRatio *
            MediaQuery.of(context).size.aspectRatio);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ClipRect(
              clipper: _MediaSizeClipper(MediaQuery.of(context).size),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: CameraPreview(controller!),
              ),
            ),
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
                        // dispose();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SpineAdd(
                                imagePath: imagePath,
                                ipAddress: widget.ipAddress!)));
                      }
                    } catch (e) {
                      print(e);
                    }
                  }),
            ),
            // if (imagePath != "")
            //   Container(
            //       width: 300,
            //       height: 300,
            //       child: Image.file(
            //         File(imagePath),
            //       ))
          ],
        ),
      ),
    );
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
