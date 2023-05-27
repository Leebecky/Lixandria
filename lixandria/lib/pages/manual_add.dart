import 'package:flutter/material.dart';
import 'package:lixandria/widgets/customTextfield.dart';

import 'package:realm/realm.dart';
import '../models/book.dart';
import '../models/tag.dart';
import '../widgets/customElevatedButton.dart';

class ManualAdd extends StatefulWidget {
  const ManualAdd({super.key});

  @override
  State<ManualAdd> createState() => _ManualAddState();
}

class _ManualAddState extends State<ManualAdd> {
  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Controllers to retrieve form values
  final _txtTitle = TextEditingController();

  // static void addBook( String? txtTitle) {
  //   var config = Configuration.local([Book.schema]);
  //   final realm = Realm(config);
  //   var data = Book(ObjectId(), title: txtTitle);
  //   realm.write(() {
  //     realm.add(data);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Book"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xff285430),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
            child: Form(
              key: _formKey,
              child: Column(children: <Widget>[
                CustomTextField(
                    _txtTitle, "Title", "Please input the book title"),
                CustomElevatedButton(context, _formKey, "Submit",
                    onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // var config2 = Configuration.local([Tag.schema]);
                    // var realm2 = Realm(config2);

                    // var car2 = Tag(ObjectId(), tagDesc: _txtTitle.text);
                    // realm2.write(() {
                    //   realm2.add(car2);
                    // });

                    var config = Configuration.local([Book.schema, Tag.schema]);
                    var realm = Realm(config);

                    var car = Book(ObjectId(), title: _txtTitle.text);
                    realm.write(() {
                      realm.add(car);
                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Book Added!")));
                  } else {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Invalid data!")));
                  }
                }),
              ]),
            )));
  }
}
