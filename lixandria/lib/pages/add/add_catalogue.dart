/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: add_catalogue.dart
Description: UI Page. Menu Selection interface for different Add Book methods
First Written On: 12/06/2023
Last Edited On:  18/06/2023
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:lixandria/pages/add/add_barcode.dart';
import 'package:lixandria/pages/add/camera.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';
import 'package:lixandria/widgets/customTextfield.dart';

import '../../constants.dart';
import 'add_manual.dart';
import 'add_spine.dart';

class AddCatalogue extends StatefulWidget {
  const AddCatalogue({super.key});

  @override
  State<AddCatalogue> createState() => _AddCatalogueState();
}

class _AddCatalogueState extends State<AddCatalogue> {
  final httpHeader = "http://";
  final apiAddress = ":8000/Lixandria_API";
  final _ipAddress = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //^ Scan Barcode Function
  // Referened from: https://pub.dev/packages/flutter_barcode_scanner/example

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes = "<Unknown>";
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // setState(() {
    //   _scanBarcode = barcodeScanRes;
    // });

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddBarcode(
              barcode: barcodeScanRes,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Add Books Method"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff285430),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomElevatedButton("Manual",
                btnSize: "medium",
                specificWidth: MediaQuery.of(context).size.width / 1.5,
                onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddManual(
                        mode: MODE_NEW,
                      )));
            }),
            CustomElevatedButton("Scan Barcode",
                btnSize: "medium",
                specificWidth: MediaQuery.of(context).size.width / 1.5,
                onPressed: () => scanBarcodeNormal()),
            CustomElevatedButton("Snap Book Spine",
                btnSize: "medium",
                specificWidth: MediaQuery.of(context).size.width / 1.5,
                onPressed: () {
              configureIpAddress(context, _ipAddress,
                  httpHeader: httpHeader,
                  apiAddress: apiAddress,
                  formKey: _formKey);
            }),
          ],
        ),
      ),
    );
  }
}

configureIpAddress(BuildContext context, TextEditingController ipAddress,
    {String? httpHeader, String? apiAddress, formKey}) {
  return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: const Text(
              "Configure IP Address",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          titlePadding: const EdgeInsets.all(0),
          actionsPadding: const EdgeInsets.all(10),
          content: Form(
              key: formKey,
              child: CustomTextField(ipAddress, "Server IP Address",
                  errorMsg: "Server Address is required!")),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, 'Cancel');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Camera(
                            navigation: (imagePath) => Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (context) => SpineAdd(
                                          imagePath: imagePath,
                                          ipAddress:
                                              "$httpHeader${ipAddress.text}$apiAddress",
                                        ))),
                          )
                      // AddSpineCamera(
                      //     ipAddress: "$httpHeader${ipAddress.text}$apiAddress")
                      //  AddSpine(
                      //       ipAddress: "$httpHeader${ipAddress.text}$apiAddress",
                      //     )
                      ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please provide the IP Address"),
                    showCloseIcon: true,
                    duration: Duration(seconds: 1),
                  ));
                }
              },
              child: const Text(
                'Confirm',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      });
}
