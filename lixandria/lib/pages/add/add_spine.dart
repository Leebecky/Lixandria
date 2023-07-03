import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lixandria/pages/add/add_spine_api.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';

import '../../constants.dart';
import '../../widgets/customDropdown.dart';

class SpineAdd extends StatefulWidget {
  final String imagePath;
  final String ipAddress;
  const SpineAdd({super.key, required this.imagePath, required this.ipAddress});

  @override
  State<SpineAdd> createState() => _SpineAddState();
}

class _SpineAddState extends State<SpineAdd> {
  String bookOrientation = ORIENTATION_UPRIGHT;
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              "API: ${widget.ipAddress}",
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: CustomDropdown(bookOrientation,
                  dropdownText: BOOK_ORIENTATION,
                  labelTxt: "Book Orientation on Shelf",
                  onChangeFun: (String? val) {
                setState(() {
                  bookOrientation = val!;
                });
              })),
          const SizedBox(height: 8.0),
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              child: Image.file(
                File(widget.imagePath),
                scale: 0.5,
              )),
          const SizedBox(height: 8.0),
          CustomElevatedButton("Submit", onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SpineAddApi(
                      apiUrl: widget.ipAddress,
                      imagePath: widget.imagePath,
                      orientation: bookOrientation,
                    )));
            // await processShelfImage(ipAddress, imagePath);
          })
        ],
      ),
    );
  }
}
