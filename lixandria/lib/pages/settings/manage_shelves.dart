/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: manage_shelves.dart
Description: UI Page. Handles the management of shelves in the system and relevant business logic.
First Written On: 12/06/2023
Last Edited On:  23/06/2023
 */

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:realm/realm.dart';

import '../../models/model_helper.dart';
import '../../models/shelf.dart';
import '../../widgets/customTextfield.dart';

class ShelfManager extends StatefulWidget {
  const ShelfManager({super.key});

  @override
  State<ShelfManager> createState() => _ShelfManagerState();
}

class _ShelfManagerState extends State<ShelfManager> {
  List<Shelf> shelves = [];
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    shelves = getShelfData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Shelves"),
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: (shelves.isEmpty)
              ? const Center(
                  child: Text(
                  "No shelves in the database",
                  style: TextStyle(fontSize: 20),
                ))
              : ListView.separated(
                  itemCount: shelves.length,
                  separatorBuilder: (context, index) => Divider(
                        color: Theme.of(context).primaryColor,
                      ),
                  itemBuilder: (context, index) => Slidable(
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            //* Delete Shelf
                            SlidableAction(
                              icon: Icons.delete_rounded,
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              onPressed: (context) {
                                showDialog(
                                    context: context,
                                    builder: (context) => deleteShelfDialog(
                                        context,
                                        shelfData: shelves[index],
                                        onComplete: () => setState(
                                            () => shelves = getShelfData())));
                              },
                            ),

                            //* Edit Shelf
                            SlidableAction(
                              icon: Icons.edit_rounded,
                              backgroundColor: Colors.yellow.shade800,
                              foregroundColor: Colors.white,
                              onPressed: (context) {
                                showDialog(
                                    context: context,
                                    builder: (context) => addShelfDialog(
                                        context, formKey,
                                        shelfData: shelves[index],
                                        isUpdate: true,
                                        onComplete: () => setState(
                                            () => shelves = getShelfData())));
                              },
                            ),
                          ],
                        ),
                        child: ListTile(
                            title: Text(
                              shelves[index].shelfName!,
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${shelves[index].booksOnShelf.length} book(s) on shelf",
                              style: const TextStyle(fontSize: 18),
                            )),
                      )),
        ),
      ),
      //* Add Shelf
      persistentFooterButtons: [
        FloatingActionButton(
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => addShelfDialog(context, formKey,
                    isUpdate: false,
                    onComplete: () => setState(() {
                          shelves = getShelfData();
                        })),
              );
            }),
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}

List<Shelf> getShelfData() {
  RealmResults<Shelf> shelfDb = ModelHelper.getAllShelves();
  return ModelHelper.convertToShelf(shelfDb);
}

addShelfDialog(context, formKey,
    {required bool isUpdate, Shelf? shelfData, onComplete}) {
  final shelfNameTxt = TextEditingController()
    ..text = (isUpdate) ? shelfData!.shelfName! : "";
  String shelfId = (isUpdate) ? shelfData!.shelfId : ObjectId().toString();
  String headerText = (isUpdate) ? "Edit" : "New";

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
      child: Text(
        "$headerText Shelf",
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    titlePadding: const EdgeInsets.all(0),
    actionsPadding: const EdgeInsets.all(10),
    content: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Form(
          key: formKey,
          child: CustomTextField(shelfNameTxt, "Shelf Name",
              errorMsg: "Shelf Name is required!")),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            Shelf data = Shelf(shelfId,
                shelfName: shelfNameTxt.text.trim(),
                booksOnShelf: (isUpdate) ? shelfData!.booksOnShelf : []);
            String dbResponse = ModelHelper.addNewShelf(data, isUpdate);

            onComplete();

            String msg = (dbResponse == "Success")
                ? (isUpdate)
                    ? "Shelf updated"
                    : "Shelf added"
                : dbResponse;

            Navigator.pop(context, "Cancel");

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg),
              showCloseIcon: true,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Please provide the shelf name"),
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
}

deleteShelfDialog(context, {required Shelf shelfData, onComplete}) {
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
        "Delete Shelf",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    titlePadding: const EdgeInsets.all(0),
    actionsPadding: const EdgeInsets.all(10),
    content: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Text(
          "Are you sure you wish to delete ${shelfData.shelfName}? This action cannot be undone!"),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (shelfData.booksOnShelf.isNotEmpty) {
            Navigator.pop(context, "Cancel");

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "Shelf cannot be deleted. Please remove all books in the shelf first."),
              showCloseIcon: true,
            ));
          } else {
            bool success = ModelHelper.deleteShelf(shelfData.shelfId);

            onComplete();

            String msg = (success)
                ? "Shelf successfully deleted!"
                : "Unexpected error encountered. Please try again.";

            Navigator.pop(context, "Cancel");

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg),
              showCloseIcon: true,
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
}
