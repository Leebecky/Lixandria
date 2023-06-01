import 'package:flutter/material.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomElevatedButton("Manage Shelves",
              btnSize: "medium",
              specificWidth: MediaQuery.of(context).size.width / 1.5,
              onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Exporting database to CSV..."),
              showCloseIcon: true,
            ));
          }),
          CustomElevatedButton("Manage Tags",
              btnSize: "medium",
              specificWidth: MediaQuery.of(context).size.width / 1.5,
              onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Exporting database to CSV..."),
              showCloseIcon: true,
            ));
          }),
          CustomElevatedButton("Export to CSV",
              btnSize: "medium",
              specificWidth: MediaQuery.of(context).size.width / 1.5,
              onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Exporting database to CSV..."),
              showCloseIcon: true,
            ));
          }),
          CustomElevatedButton("Clear Database",
              btnSize: "medium",
              specificWidth: MediaQuery.of(context).size.width / 1.5,
              onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Clearing database..."), showCloseIcon: true));
          }),
          CustomElevatedButton("Credits",
              btnSize: "medium",
              specificWidth: MediaQuery.of(context).size.width / 1.5,
              onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Displaying credits..."), showCloseIcon: true));
          }),
        ],
      ),
    );
  }
}
