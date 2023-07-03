import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lixandria/pages/add/add_manual.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';
import 'package:realm/realm.dart';

import '../../constants.dart';
import '../../main.dart';
import '../../models/book.dart';
import '../../models/model_helper.dart';
import 'package:http/http.dart';

import '../../models/shelf.dart';
import '../../widgets/customAlertDialog.dart';
import '../../widgets/customDropdown.dart';

class SpineBookDisplay extends StatefulWidget {
  final List<String> spineText;
  const SpineBookDisplay({super.key, required this.spineText});

  @override
  State<SpineBookDisplay> createState() => _SpineBookDisplayState();
}

class _SpineBookDisplayState extends State<SpineBookDisplay> {
  Map<String, String> shelfSelection = {};
  late Future<Map<int, List<Book>>> booksFromAPI;
  List<DropdownMenuItem<String>> shelfDropdown = [];
  Map<int, int> bookSelectionCopy = {};
  final _shelfFormKey = GlobalKey<FormState>();
  Map<String, GlobalKey<FormState>> _formKeys = {};
  Map<int, int> bookSelection = {};
  @override
  void initState() {
    super.initState();
    booksFromAPI = fetchBookData(widget.spineText);
    List<DropdownMenuItem<String>> list = generateShelfDropdown(context);
    shelfDropdown.addAll(list);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, List<Book>>>(
      future: booksFromAPI,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<int> keys = snapshot.data!.keys.toList();
          for (int i = 0; i < snapshot.data!.length; i++) {
            bookSelection.putIfAbsent(keys[i], () => 0);
            //* Generating Shelf Dropdown controllers
            shelfSelection.putIfAbsent(
                keys[i].toString(),
                () => (shelfDropdown.length > 1)
                    ? shelfDropdown.last.value!
                    : "-1");
            //* Generating Form Keys
            _formKeys.putIfAbsent(
                keys[i].toString(), () => GlobalKey<FormState>());
          }

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
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, ind) {
                        int index = keys[ind];
                        return Slidable(
                            endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              CustomAlertDialog(
                                                  context,
                                                  "Remove book?",
                                                  "Would you like to remove this book?",
                                                  confirmOnPressed: () {
                                                Navigator.of(context).pop();

                                                setState(() {
                                                  bookSelection.remove(index);
                                                  snapshot.data!.remove(index);
                                                  shelfSelection
                                                      .remove(index.toString());
                                                  _formKeys
                                                      .remove(index.toString());
                                                });
                                              }));
                                    },
                                    icon: Icons.delete_rounded,
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red,
                                  ),
                                  SlidableAction(
                                    onPressed: (context) async {
                                      int newBookSelection = await showDialog(
                                          context: context,
                                          builder: (context) => swapBookDialog(
                                              context,
                                              spineText:
                                                  widget.spineText[index],
                                              bookList: snapshot.data![index]!,
                                              initialSelection:
                                                  bookSelection[index]!));
                                      setState(() {
                                        if (newBookSelection > -1) {
                                          bookSelection[index] =
                                              newBookSelection;
                                        }
                                      });
                                    },
                                    icon: Icons.change_circle_rounded,
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                  )
                                ]),
                            child: ListTile(
                              title: Text(
                                snapshot.data![index]![bookSelection[index]!]
                                    .title!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              subtitle: Form(
                                key: _formKeys[index.toString()],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(snapshot
                                        .data![index]![bookSelection[index]!]
                                        .author!),
                                    CustomDropdown(
                                        shelfSelection[index.toString()],
                                        labelTxt: "Shelf",
                                        dropdownItems: shelfDropdown,
                                        validateFun: (String? val) {
                                      if (val == "-1") {
                                        return "Please select a valid shelf!";
                                      }
                                      return null;
                                    }, onChangeFun: (String? val) {
                                      if (val == "-1") {
                                        showDialog(
                                          context: context,
                                          builder: (context) => addShelfDialog(
                                            context,
                                            _shelfFormKey,
                                            onComplete: () => setState(() {
                                              shelfDropdown =
                                                  generateShelfDropdown(
                                                      context);
                                              shelfSelection[index.toString()] =
                                                  shelfDropdown[
                                                          shelfDropdown.length -
                                                              1]
                                                      .value!;
                                            }),
                                          ),
                                        );
                                      } else {
                                        setState(() {
                                          shelfSelection[index.toString()] =
                                              val!;
                                        });
                                      }
                                    }),
                                  ],
                                ),
                              ),
                              leading: SizedBox(
                                width: 50,
                                child: Image.network(
                                  snapshot.data![index]![bookSelection[index]!]
                                      .coverImage!,
                                  height: 140,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_rounded),
                                ),
                              ),
                              onTap: () async {
                                final updatedData = await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => AddManual(
                                              bookRecord:
                                                  snapshot.data![index]![
                                                      bookSelection[index]!],
                                              shelfId: shelfSelection[
                                                  index.toString()],
                                              mode: MODE_NEW_SHELF,
                                            )));

                                if (!mounted) return;
                                setState(() {
                                  snapshot.data![index]![
                                          bookSelection[index]!] =
                                      (updatedData["book"] as Book);
                                  shelfSelection[index.toString()] =
                                      updatedData["shelf"];
                                });
                              },
                            ));
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ),
                  CustomElevatedButton("Save All", onPressed: () {
                    bool validation = true;
                    String msg = "";
                    _formKeys.forEach((key, value) {
                      var validate = value.currentState?.validate();
                      if (validate == false) validation = false;
                    });

                    if (validation) {
                      bool success = true;
                      for (int i = 0; i < snapshot.data!.length; i++) {
                        success = ModelHelper.addNewBook(
                            snapshot.data![keys[i]]![bookSelection[keys[i]]!],
                            shelfSelection[keys[i].toString()]!);

                        if (!success) {
                          break;
                        }
                      }

                      if (success) {
                        msg = "Saving all books to database";
                      } else {
                        msg =
                            "Error encountered while saving books. Operation aborted.";
                      }
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(msg)));
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (c) => const AppScaffold()),
                          (route) => false);
                    }
                  }),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ));
        } else if (snapshot.hasError) {
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
              body: Text("An error was encountered: ${snapshot.error}"));
        }

        // By default, show a loading spinner.
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
            body: const Center(
                child: CircularProgressIndicator(
              strokeWidth: 8.0,
            )));
      },
    );
  }

//? Retrieve Book Data from Google Books API based on detected spine text
  Future<Map<int, List<Book>>> fetchBookData(List<String> spineText) async {
    Map<int, List<Book>> finalBookSet = {};

    for (int i = 0; i < spineText.length; i++) {
      List<Book> list = [];
      String text = spineText[i];
      final response = await get(
          Uri.parse("https://www.googleapis.com/books/v1/volumes?q=$text"));

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        List<Book> retrieved =
            ModelHelper.decodeBookFromJson(response.body, maxResponses: 5);
        if (retrieved.isNotEmpty) {
          list.addAll((retrieved));
        } else {
          // If no books was found, return detected spine text as title
          list.add(ModelHelper.generateEmptyBook()..title = text);
        }
      } else {
        // If no books was found, return detected spine text as title
        list.add(ModelHelper.generateEmptyBook()..title = text);
      }
      finalBookSet.putIfAbsent(i, () => list);
    }
    return finalBookSet;
  }

//? Generate the dropdown options for the Shelves
  List<DropdownMenuItem<String>> generateShelfDropdown(context) {
    RealmResults<Shelf> shelfDb = ModelHelper.getAllShelves();
    List<DropdownMenuItem<String>> list = shelfDb
        .map<DropdownMenuItem<String>>(
          (x) => DropdownMenuItem<String>(
              value: x.shelfId, child: Text(x.shelfName!)),
        )
        .toList();

    //^ Inititialise [Add New Shelf] option
    DropdownMenuItem<String> addShelf = const DropdownMenuItem<String>(
        value: "-1",
        child: Row(
          children: [
            Icon(Icons.add_circle_outline_rounded),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                "Add New Shelf",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ));
    list.insert(0, addShelf);

    return list;
  }

//? UI for Book Swap Selection dialog
  Widget swapBookDialog(BuildContext context,
      {required String spineText,
      required List<Book> bookList,
      required int initialSelection,
      onComplete}) {
    int selectedIndex = initialSelection;

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
        child: Column(
          children: [
            const Text(
              "Books Returned from API for: ",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(spineText,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15))
          ],
        ),
      ),
      titlePadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.all(10),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  //* Shelves
                  children: List.generate(
                    bookList.length,
                    (index) => Stack(children: [
                      RadioListTile<int>(
                        value: index,
                        groupValue: selectedIndex,
                        onChanged: (int? val) =>
                            setState(() => selectedIndex = val!),
                        title: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 2.0),
                            //* Items in shelf
                            child: Container(
                              margin: const EdgeInsets.only(left: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xff484357),
                              ),
                              child: Card(
                                color: const Color(0xff484357),
                                child: Column(children: [
                                  (bookList[index].coverImage == null ||
                                          bookList[index].coverImage == "")
                                      ? const Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Placeholder(
                                              fallbackHeight: 140,
                                            ),
                                            Center(
                                                child: Text("No image provided",
                                                    style: TextStyle(
                                                        color: Colors.white)))
                                          ],
                                        )
                                      : getImageDisplay(
                                          bookList[index].coverImage!),
                                  const Divider(
                                    color: Colors.white,
                                  ),
                                  Text(
                                    bookList[index].title!,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white),
                                    maxLines: null,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    bookList[index].author!,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                    textAlign: TextAlign.center,
                                    maxLines: null,
                                  )
                                ]),
                              ),
                            )),
                      )
                    ]),
                  )),
            )),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, -1),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, selectedIndex);

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Book selection updated"),
              showCloseIcon: true,
            ));
          },
          child: const Text(
            'Confirm',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
