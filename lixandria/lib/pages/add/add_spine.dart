import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lixandria/pages/add/add_spine_api.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';

class SpineAdd extends StatelessWidget {
  final String imagePath;
  final String ipAddress;
  const SpineAdd({super.key, required this.imagePath, required this.ipAddress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Book"),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff285430),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              "API: $ipAddress",
              style: const TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              child: Image.file(
                File(imagePath),
                scale: 0.5,
              )),
          CustomElevatedButton("Submit", onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SpineAddApi(
                      apiUrl: ipAddress,
                      imagePath: imagePath,
                    )));
            // await processShelfImage(ipAddress, imagePath);
          })
        ],
      ),
    );
  }
}
