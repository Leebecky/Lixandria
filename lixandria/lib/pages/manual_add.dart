import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lixandria/widgets/customTextfield.dart';

import 'package:realm/realm.dart';
import '../models/book.dart';
import '../models/tag.dart';
import '../widgets/customDropdown.dart';
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
  final _txtSubtitle = TextEditingController();
  final _txtAuthor = TextEditingController();
  final _txtSeriesNumber = TextEditingController();
  final _txtPublisher = TextEditingController();
  final _txtDescription = TextEditingController();
  final _txtNotes = TextEditingController();
  final _txtLocation = TextEditingController();
  final _txtOwnershipStatus = TextEditingController();
  bool? _isRead = false;
  double _bookRating = 3;

  List<String> ownershipStatus = ["Owned", "Borrowed", "Wishlist"];
  List<String> shelves = ["Shelf 1", "Library", "White Bedroom 2nd"];

  @override
  Widget build(BuildContext context) {
    String _ownershipSelection = ownershipStatus.first;
    String _shelf = shelves.first;

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
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  //* Input Fields
                  CustomTextField(_txtTitle, "Title",
                      errorMsg: "Please input the book title",
                      isRequired: true,
                      helpMsg: "*Required"
                      //   customValidator: (value) {
                      // if (value == "AAA") {
                      //   return "Testing Complete";
                      // }}
                      ),

                  CustomTextField(_txtSubtitle, "Subtitle", isRequired: false),
                  CustomTextField(_txtAuthor, "Author",
                      errorMsg: "Please input the author",
                      helpMsg: "*Required"),

                  CustomTextField(_txtSeriesNumber, "Series Number",
                      isRequired: false, isNumericOnly: true),

                  CustomTextField(_txtPublisher, "Publisher",
                      isRequired: false),
                  CustomTextField(_txtDescription, "Description",
                      isRequired: false),
                  CustomTextField(_txtNotes, "Notes", isRequired: false),
                  CustomTextField(_txtLocation, "Location", isRequired: false),

                  CustomDropdown(_ownershipSelection, ownershipStatus,
                      labelTxt: "Ownership Status", onChangeFun: (String? val) {
                    setState(() {
                      _ownershipSelection = val!;
                    });
                  }),

                  // TODO Dropdown for Shelf - Retrieve from DB + Add to DB
                  CustomDropdown(_shelf, shelves, labelTxt: "Shelf",
                      onChangeFun: (String? val) {
                    setState(() {
                      _shelf = val!;
                    });
                  }),

                  // TODO Book Rating
                  Container(
                    // padding: const EdgeInsets.symmetric(vertical: 12.0),
                    // width: MediaQuery.sizeOf(context).width,
                    decoration: BoxDecoration(border: Border.all()),
                    child: RatingBar(
                      wrapAlignment: WrapAlignment.center,
                      initialRating: 3,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      ratingWidget: RatingWidget(
                        full: const Icon(Icons.star_rounded),
                        half: const Icon(Icons.star_half_rounded),
                        empty: const Icon(Icons.star_outline_rounded),
                      ),
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      onRatingUpdate: (rating) {
                        _bookRating = rating;

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Rating: ${_bookRating.toString()}")));
                      },
                    ),
                  ),

                  // TODO Tags  _Chips

                  CheckboxListTile(
                      title: const Text("Is Read?"),
                      value: _isRead,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? val) => setState(() {
                            _isRead = val!;
                          })),

                  CustomElevatedButton("Submit", onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // var config = Configuration.local([Book.schema, Tag.schema]);
                      // var realm = Realm(config);

                      // var car = Book(ObjectId(), title: _txtTitle.text);
                      // realm.write(() {
                      //   realm.add(car);
                      // });

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Book has been saved !")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "Invalid data found. Please verify your input!")));
                    }
                  }),
                ]),
              ),
            )));
  }

  //^ Cleaning Up Resources
  @override
  void dispose() {
    _txtAuthor.dispose();
    _txtDescription.dispose();
    _txtLocation.dispose();
    _txtNotes.dispose();
    _txtOwnershipStatus.dispose();
    _txtPublisher.dispose();
    _txtSeriesNumber.dispose();
    _txtSubtitle.dispose();
    _txtTitle.dispose();
    super.dispose();
  }
}
