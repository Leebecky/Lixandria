import 'package:flutter/material.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';

import '../../constants.dart';
import 'add_manual.dart';

class AddCatalogue extends StatefulWidget {
  const AddCatalogue({super.key});

  @override
  State<AddCatalogue> createState() => _AddCatalogueState();
}

class _AddCatalogueState extends State<AddCatalogue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Books"),
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
                onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Scanning barcode..."), showCloseIcon: true));
            }),
            CustomElevatedButton("Scan Book Spine",
                btnSize: "medium",
                specificWidth: MediaQuery.of(context).size.width / 1.5,
                onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Scanning Book Spine..."),
                  showCloseIcon: true));
            }),
          ],
        ),
      ),
    );
  }
}
