import 'package:flutter/material.dart';
import 'package:lixandria/pages/settings/credits.dart';
import 'package:lixandria/pages/settings/manage_tags.dart';
import 'package:lixandria/widgets/customAlertDialog.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';
import 'package:realm/realm.dart';

import '../../models/book.dart';
import '../../models/shelf.dart';
import '../../models/tag.dart';
import 'manage_shelves.dart';

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
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ShelfManager()));
          }),
          CustomElevatedButton("Manage Tags",
              btnSize: "medium",
              specificWidth: MediaQuery.of(context).size.width / 1.5,
              onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TagManager()));
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
            showDialog(
                context: context,
                builder: (context) => CustomAlertDialog(
                        context,
                        "Clear Database",
                        "Are you sure you wish to clear the database? Data cannot be restored beyond this point.",
                        confirmOnPressed: () {
                      clearDatabase(context);
                    }));
          }),
          CustomElevatedButton("Credits",
              btnSize: "medium",
              specificWidth: MediaQuery.of(context).size.width / 1.5,
              onPressed: () {
            showDialog(
                context: context, builder: ((context) => const CreditsPage()));
          }),
        ],
      ),
    );
  }

  void clearDatabase(BuildContext context) {
    Navigator.pop(context, 'Cancel');

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Clearing database..."),
      showCloseIcon: false,
      duration: Duration(seconds: 5),
    ));

    final realmConfig =
        Configuration.local([Shelf.schema, Book.schema, Tag.schema]);
    var realm = Realm(realmConfig);
    // realm.deleteAll()
    //Get realm's file path
    final path = realm.config.path;
    // You must close a realm before deleting it
    realm.close();
    // Delete the realm
    Realm.deleteRealm(path);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Database cleared"),
      showCloseIcon: true,
    ));
  }
}
