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
  late Future<List<Book>> booksFromAPI;
  List<DropdownMenuItem<String>> shelfDropdown = [];

  final _shelfFormKey = GlobalKey<FormState>();
  Map<String, GlobalKey<FormState>> _formKeys = {};

  @override
  void initState() {
    super.initState();
    booksFromAPI = fetchBookData(widget.spineText);
    List<DropdownMenuItem<String>> list = generateShelfDropdown(context);
    shelfDropdown.addAll(list);

    // DropdownMenuItem<String> addShelf = DropdownMenuItem<String>(
    //   value: "-1",
    //   child: const Row(
    //     children: [
    //       Icon(Icons.add_circle_outline_rounded),
    //       Padding(
    //         padding: EdgeInsets.only(left: 8.0),
    //         child: Text(
    //           "Add New Shelf",
    //           style: TextStyle(fontWeight: FontWeight.bold),
    //         ),
    //       ),
    //     ],
    //   ),
    //   onTap: () {
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(const SnackBar(content: Text("Test")));
    //   },
    // );

    // if (shelfDropdown[0].value != "-1") {
    //   shelfDropdown.insert(0, addShelf);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: booksFromAPI,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          for (int i = 0; i < snapshot.data!.length; i++) {
            //* Generating Shelf Dropdown controllers

            shelfSelection.putIfAbsent(
                i.toString(),
                () => (shelfDropdown.length > 1)
                    ? shelfDropdown.last.value!
                    : "-1");
            //* Generating Form Keys
            _formKeys.putIfAbsent(i.toString(), () => GlobalKey<FormState>());
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
                      itemBuilder: (context, index) => Slidable(
                          endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => CustomAlertDialog(
                                                context,
                                                "Remove book?",
                                                "Would you like to remove this book?",
                                                confirmOnPressed: () {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                snapshot.data!.removeAt(index);
                                                shelfSelection
                                                    .remove(index.toString());
                                                _formKeys
                                                    .remove(index.toString());
                                              });
                                            }));

                                    // setState(() {
                                    //   snapshot.data!.removeAt(index);
                                    //   shelfSelection.remove(index.toString());
                                    //   _formKeys.remove(index.toString());
                                    // });
                                  },
                                  icon: Icons.delete_rounded,
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                )
                              ]),
                          child: ListTile(
                            title: Text(
                              snapshot.data![index].title!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            subtitle: Form(
                              key: _formKeys[index.toString()],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(snapshot.data![index].author!),
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
                                                generateShelfDropdown(context);
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
                                        shelfSelection[index.toString()] = val!;
                                      });
                                    }
                                  }),
                                ],
                              ),
                            ),
                            leading: SizedBox(
                              width: 50,
                              child: Image.network(
                                snapshot.data![index].coverImage!,
                                height: 140,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_rounded),
                              ),
                            ),
                            onTap: () async {
                              final updatedData = await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => AddManual(
                                            bookRecord: snapshot.data![index],
                                            shelfId: shelfSelection[
                                                index.toString()],
                                            mode: MODE_NEW_SHELF,
                                          )));

                              if (!mounted) return;
                              setState(() {
                                snapshot.data![index] =
                                    (updatedData["book"] as Book);
                                shelfSelection[index.toString()] =
                                    updatedData["shelf"];
                              });
                            },
                          )),
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
                            snapshot.data![i], shelfSelection[i.toString()]!);

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

          // return AddManual(
          //   mode: MODE_NEW_DATA,
          //   bookRecord: snapshot.data!.first,
          //   shelfId: "-1",
          // );
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

  Future<List<Book>> fetchBookData(List<String> spineText) async {
    List<Book> list = [];

    for (String text in spineText) {
      final response = await get(
          Uri.parse("https://www.googleapis.com/books/v1/volumes?q=$text"));

      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        List<Book> retrieved =
            ModelHelper.decodeBookFromJson(response.body, maxResponses: 1);

        if (retrieved.isNotEmpty) {
          list.add((retrieved[0]));
        }
      } else {
        // If no books was found, return detected spine text as title
        list.add(Book(ObjectId().toString(), title: text));
      }
    }

    return list;
  }

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
}
