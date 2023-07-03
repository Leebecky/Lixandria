import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:lixandria/pages/settings/credits.dart';
import 'package:lixandria/pages/settings/manage_tags.dart';
import 'package:lixandria/widgets/customAlertDialog.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';
import 'package:realm/realm.dart';
import '../../models/book.dart';
import '../../models/model_helper.dart';
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
          CustomElevatedButton("Export to Excel",
              btnSize: "medium",
              specificWidth: MediaQuery.of(context).size.width / 1.5,
              onPressed: () async {
            await exportAsExcel();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Exporting database to Excel..."),
              ));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    "Database exported to Excel. Please check your Downloads folder"),
                showCloseIcon: true,
              ));
            }
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

Future<File> exportAsExcel() async {
  Excel excelFile = Excel.createExcel();
  Sheet tagSheet = excelFile["Tags"];
  Sheet bookSheet = excelFile["Books"];
  Sheet shelfSheet = excelFile["Shelves"];

  // Data
  List<Shelf> dbData = ModelHelper.convertToShelf(ModelHelper.getAllShelves());
  List<Tag> tagList =
      ModelHelper.convertToTag(dataFromResults: ModelHelper.getAllTags());

  // Tags
  tagSheet.appendRow(["tagId", "tagDesc"]);
  for (var element in tagList) {
    tagSheet.appendRow([element.tagId, element.tagDesc]);
  }

  // Shelf
  shelfSheet.appendRow(["shelfId", "shelfName", "bookCount"]);
  for (Shelf shelf in dbData) {
    shelfSheet
        .appendRow([shelf.shelfId, shelf.shelfName, shelf.booksOnShelf.length]);
  }

  // Book
  bookSheet.appendRow([
    "shelfId",
    "bookId",
    "title",
    "subtitle",
    "author",
    "publisher",
    "description",
    "userNotes",
    "location",
    "ownershipStatus",
    "bookRating",
    "isRead",
    "seriesNumber",
    "coverImage",
    "isbnCode",
    "tags"
  ]);

  for (Shelf shelf in dbData) {
    for (Book book in shelf.booksOnShelf) {
      List<String> bookTags = book.tags.map((e) => e.tagId).toList();
      bookSheet.appendRow([
        shelf.shelfId,
        book.bookId,
        book.title,
        book.subTitle,
        book.author,
        book.publisher,
        book.description,
        book.userNotes,
        book.location,
        book.ownershipStatus,
        book.bookRating,
        book.isRead,
        book.seriesNumber,
        book.coverImage,
        book.isbnCode,
        bookTags.join(",")
      ]);
    }
  }

  String? downloadDirectory;
  Directory? directory;
  try {
    directory = Directory('/storage/emulated/0/Download');
    // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
    if (!await directory.exists()) {
      directory = await getExternalStorageDirectory();
    }
    downloadDirectory = directory!.path;
  } catch (e) {
    debugPrint("Unable to retrieve folder path");
  }

  // Save File
  DateTime time = DateTime.now();
  String formattedDate =
      "${time.year.toString()}${time.month.toString().padLeft(2, '0')}${time.day.toString().padLeft(2, '0')}${time.hour.toString()}${time.minute.toString().padLeft(2, '0')}${time.second.toString().padLeft(2, '0')}";
  var fileBytes =
      excelFile.save(fileName: "Lixandria-UserData-$formattedDate.xlsx");
  return File("$downloadDirectory/Lixandria-UserData-$formattedDate.xlsx")
      .writeAsBytes(fileBytes!);
}
