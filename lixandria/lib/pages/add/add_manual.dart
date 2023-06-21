import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lixandria/constants.dart';
import 'package:lixandria/main.dart';
import 'package:lixandria/models/model_helper.dart';
import 'package:lixandria/models/shelf.dart';
import 'package:lixandria/widgets/customAlertDialog.dart';
import 'package:lixandria/widgets/customTextfield.dart';

import 'package:realm/realm.dart';
import '../../models/book.dart';
import '../../models/tag.dart';
import '../../widgets/customDropdown.dart';
import '../../widgets/customElevatedButton.dart';

class AddManual extends StatefulWidget {
  final Book? bookRecord;
  final String? mode;
  final String? shelfId;
  const AddManual({super.key, this.mode, this.bookRecord, this.shelfId});

  @override
  State<AddManual> createState() => _AddManualState();
}

class _AddManualState extends State<AddManual> {
  // Form Key
  final _formKey = GlobalKey<FormState>();
  final _shelfFormKey = GlobalKey<FormState>();
  final _tagFormKey = GlobalKey<FormState>();

  // Controllers to retrieve form values
  final _txtTitle = TextEditingController();
  final _txtSubtitle = TextEditingController();
  final _txtAuthor = TextEditingController();
  final _txtSeriesNumber = TextEditingController()..text = "0";
  final _txtPublisher = TextEditingController();
  final _txtDescription = TextEditingController();
  final _txtNotes = TextEditingController();
  final _txtLocation = TextEditingController();
  final _txtIsbnCode = TextEditingController();
  bool? _isRead = false;
  double _bookRating = 3;
  String? _coverImage = "";

  List<String> ownershipStatus = ["Owned", "Borrowed", "Wishlist"];

  List<DropdownMenuItem<String>> shelfDropdown = [];
  String ownershipSelection = "";
  String shelf = "";

  bool _isCoverImageExpanded = false;

  @override
  void initState() {
    super.initState();
    List<DropdownMenuItem<String>> list = generateShelfDropdown(context);
    shelfDropdown.addAll(list);
    ownershipSelection = ownershipStatus.first;
    shelf = (shelfDropdown.length > 1) ? shelfDropdown[1].value! : "-1";

    //^ Set Values if EDIT / Barcode Add
    if (widget.mode != MODE_NEW) {
      _txtTitle.text = widget.bookRecord!.title!;
      _txtSubtitle.text = widget.bookRecord!.subTitle!;
      _txtAuthor.text = widget.bookRecord!.author!;
      _txtSeriesNumber.text = widget.bookRecord!.seriesNumber!.toString();
      _txtPublisher.text = widget.bookRecord!.publisher!;
      _txtDescription.text = widget.bookRecord!.description!;
      _txtNotes.text = widget.bookRecord!.userNotes!;
      _txtLocation.text = widget.bookRecord!.location!;
      _txtIsbnCode.text = widget.bookRecord!.isbnCode!;
      _isRead = widget.bookRecord!.isRead;
      shelf = widget.shelfId!;
      ownershipSelection = widget.bookRecord!.ownershipStatus!;
      _bookRating = widget.bookRecord!.bookRating!;
      _coverImage = widget.bookRecord!.coverImage;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: (widget.mode == MODE_EDIT)
              ? const Text("Edit Book")
              : const Text("Add Book"),
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  // * Cover Image
                  Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      child: InputDecorator(
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        child: ExpansionPanelList(
                            elevation: 0,
                            expandedHeaderPadding: const EdgeInsets.all(8.0),
                            expansionCallback: (int index, bool isExpanded) {
                              setState(() {
                                _isCoverImageExpanded = !_isCoverImageExpanded;
                              });
                            },
                            children: [
                              ExpansionPanel(
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  headerBuilder: (context, isExpanded) =>
                                      const ListTile(
                                          title: Text(
                                        "Cover Image",
                                        // textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      )),
                                  body: (_coverImage == null ||
                                          _coverImage == "")
                                      ? CustomElevatedButton(
                                          "Add Image",
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Don't touch me!")));
                                          },
                                        )
                                      : Image.network(
                                          widget.bookRecord!.coverImage!,
                                          height: 140,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            alignment: Alignment.center,
                                            height: 140,
                                            child: const Stack(
                                              children: [
                                                Placeholder(),
                                                Center(
                                                  child: Text(
                                                    "Unable to load image",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                  isExpanded: _isCoverImageExpanded,
                                  canTapOnHeader: true)
                            ]),
                      )),

                  //* Input Fields
                  CustomTextField(_txtTitle, "Title",
                      errorMsg: "Please input the book title",
                      isRequired: true,
                      helpMsg: "*Required",
                      isMultiline: true),

                  CustomTextField(_txtSubtitle, "Subtitle", isRequired: false),
                  CustomTextField(_txtAuthor, "Author",
                      errorMsg: "Please input the author",
                      helpMsg: "*Required"),

                  CustomTextField(_txtIsbnCode, "ISBN Code", isRequired: false),

                  CustomTextField(_txtSeriesNumber, "Series Number",
                      isRequired: false, isNumericOnly: true),

                  CustomTextField(_txtPublisher, "Publisher",
                      isRequired: false),
                  CustomTextField(_txtDescription, "Description",
                      isRequired: false, isMultiline: true),
                  CustomTextField(_txtNotes, "Notes",
                      isRequired: false, isMultiline: true),
                  CustomTextField(_txtLocation, "Location", isRequired: false),

                  CustomDropdown(ownershipSelection,
                      dropdownText: ownershipStatus,
                      labelTxt: "Ownership Status", onChangeFun: (String? val) {
                    setState(() {
                      ownershipSelection = val!;
                    });
                  }),

                  CustomDropdown(shelf,
                      labelTxt: "Shelf",
                      dropdownItems: shelfDropdown, validateFun: (String? val) {
                    if (val == "-1") {
                      return "Please select a valid shelf!";
                    }
                    return null;
                  }, onChangeFun: (String? val) {
                    if (val == "-1") {
                      showDialog(
                          context: context,
                          builder: (context) => addShelfDialog(
                              context, _shelfFormKey,
                              onComplete: () => setState(() {
                                    shelfDropdown =
                                        generateShelfDropdown(context);
                                    shelf =
                                        shelfDropdown[shelfDropdown.length - 1]
                                            .value!;
                                  })));
                    } else {
                      setState(() {
                        shelf = val!;
                      });
                    }
                  }),

                  Container(
                    padding: const EdgeInsets.all(8.0),
                    width: double.infinity,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Book Rating"),
                      child: RatingBar(
                        initialRating: _bookRating,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                          full: const Icon(Icons.star_rounded),
                          half: const Icon(Icons.star_half_rounded),
                          empty: const Icon(Icons.star_outline_rounded),
                        ),
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        onRatingUpdate: (rating) {
                          _bookRating = rating;
                        },
                      ),
                    ),
                  ),

                  // TODO Tags - Chips
                  Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      child: InputDecorator(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Book Tags"),
                          child: Column(
                            children: [
                              MenuItemButton(
                                onPressed: () => print("PING"),
                                trailingIcon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5))),
                                child: const Text(
                                  "Select Tags",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Wrap(
                                runSpacing: 2.5,
                                spacing: 2.5,
                                children: [
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                  Chip(label: Text("Romance")),
                                ],
                              )
                            ],
                          ))),

                  CheckboxListTile(
                      title: const Text("Is Read?"),
                      value: _isRead,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? val) => setState(() {
                            _isRead = val!;
                          })),

                  CustomElevatedButton(
                      (widget.mode == MODE_EDIT)
                          ? "Update"
                          : (widget.mode == MODE_NEW_SHELF)
                              ? "Save Details"
                              : "Submit", onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String bookId = (widget.mode == MODE_EDIT)
                          ? widget.bookRecord!.bookId
                          : ObjectId().toString();
                      Book data = Book(bookId,
                          title: _txtTitle.text,
                          subTitle: _txtSubtitle.text,
                          author: _txtAuthor.text,
                          publisher: _txtPublisher.text,
                          description: _txtDescription.text,
                          userNotes: _txtNotes.text,
                          location: _txtLocation.text,
                          bookRating: _bookRating,
                          isRead: _isRead,
                          seriesNumber: int.parse(_txtSeriesNumber.text),
                          isbnCode: _txtIsbnCode.text,
                          ownershipStatus: ownershipSelection,
                          coverImage: _coverImage);

                      if (widget.mode == MODE_NEW_SHELF) {
                        //* If New Shelf, return details
                        Navigator.pop(context, {"book": data, "shelf": shelf});
                      } else {
                        //* Else, save to database
                        bool realmSuccess = ModelHelper.addNewBook(data, shelf,
                            oldShelfId: widget.shelfId,
                            isUpdate: (widget.mode == MODE_EDIT));

                        if (realmSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Book has been saved!"),
                                  showCloseIcon: true));
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (c) => const AppScaffold()),
                              (route) => false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "Error saving book to database. Please try again!"),
                              showCloseIcon: true));
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "Invalid data found. Please verify your input!"),
                          showCloseIcon: true));
                    }
                  }),

                  //* Delete
                  (widget.mode == MODE_EDIT)
                      ? CustomElevatedButton("Delete", btnColour: Colors.red,
                          onPressed: () {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) =>
                                  CustomAlertDialog(context, "Delete Book",
                                      'Are you sure you wish to delete this book?',
                                      confirmOnPressed: () {
                                    bool realmSuccess = ModelHelper.deleteBook(
                                        widget.bookRecord!.bookId);
                                    if (realmSuccess) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text("Book has been deleted"),
                                        showCloseIcon: true,
                                      ));

                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (c) =>
                                                  const AppScaffold()),
                                          (route) => false);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            "Unexpected error occurred. Please try again."),
                                        showCloseIcon: true,
                                      ));
                                    }
                                  }));
                        })
                      : Container(),
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
    _txtPublisher.dispose();
    _txtSeriesNumber.dispose();
    _txtSubtitle.dispose();
    _txtTitle.dispose();
    _txtIsbnCode.dispose();
    super.dispose();
  }
}

addShelfDialog(context, formKey, {onComplete}) {
  final shelfNameTxt = TextEditingController()..text = "";
  String shelfId = ObjectId().toString();

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
          "New Shelf",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    shelfName: shelfNameTxt.text, booksOnShelf: []);
                bool success = ModelHelper.addNewShelf(data, false);

                onComplete();

                String msg = (success)
                    ? "Shelf added"
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
            ))
      ]);
}

addTagDialog(context, formKey, {onComplete}) {
  final tagNameTxt = TextEditingController()..text = "";
  String tagId = ObjectId().toString();

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
          "New Tag",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      titlePadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.all(10),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
            key: formKey,
            child: CustomTextField(tagNameTxt, "Tag Description",
                errorMsg: "Tag Description is required!")),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Tag data = Tag(
                  tagId,
                  tagDesc: tagNameTxt.text,
                );
                bool success = ModelHelper.addNewTag(data, false);

                onComplete();

                String msg = (success)
                    ? "Tag added"
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
            ))
      ]);
}
