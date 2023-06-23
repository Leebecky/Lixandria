import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lixandria/constants.dart';
import 'package:lixandria/main.dart';
import 'package:lixandria/models/model_helper.dart';
import 'package:lixandria/models/shelf.dart';
import 'package:lixandria/pages/add/camera.dart';
import 'package:lixandria/widgets/customAlertDialog.dart';
import 'package:lixandria/widgets/customTextfield.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
  List<Tag> _bookTags = [];
  List<Tag> _tagsNotInDb = [];

  List<String> ownershipStatus = OWNERSHIP_SET;

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
      _bookTags = widget.bookRecord!.tags;
      _tagsNotInDb = _bookTags.where((x) => !x.isInDatabase).toList();
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
                                  body: Column(children: [
                                    CustomElevatedButton(
                                        (_coverImage == null ||
                                                _coverImage == "")
                                            ? "Add Image"
                                            : "Edit Image",
                                        onPressed: () async {
                                      String img = "";
                                      img = await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => Camera(
                                                  navigation: (imagePath) =>
                                                      Navigator.pop(context,
                                                          imagePath))));

                                      setState(() => _coverImage = img);
                                    }),
                                    (_coverImage != null && _coverImage != "")
                                        ? getImageDisplay(_coverImage!)
                                        : Container(),
                                  ]),
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

                  Container(
                      constraints:
                          const BoxConstraints(maxHeight: 225, minHeight: 150),
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      child: InputDecorator(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Book Tags"),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                MenuItemButton(
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
                                  onPressed: () async {
                                    var tagSelection = await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            tagSelectionDialog(_tagFormKey,
                                                bookTags: _bookTags));
                                    if (tagSelection != "Cancel") {
                                      setState(() {
                                        _bookTags = tagSelection;
                                        _bookTags.addAll(_tagsNotInDb);
                                      });
                                    }
                                  },
                                  child: const Text(
                                    "Select Tags",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Wrap(
                                  spacing: 5.0,
                                  children: _bookTags
                                      .map((x) => Chip(
                                            label: Text(x.tagDesc!),
                                            deleteIcon: const Icon(
                                                Icons.cancel_rounded),
                                            onDeleted: (!x.isInDatabase)
                                                ? () {
                                                    if (!x.isInDatabase) {
                                                      setState(() =>
                                                          _bookTags.remove(x));
                                                    }
                                                  }
                                                : null,
                                          ))
                                      .toList(),
                                )
                              ],
                            ),
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
                              : "Submit", onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String bookId = (widget.mode == MODE_EDIT)
                          ? widget.bookRecord!.bookId
                          : ObjectId().toString();

                      String newPath = "";

                      //* Process Cover Image
                      if (_coverImage != null && _coverImage != "") {
                        bool isNetwork =
                            Uri.parse(_coverImage!).host.isNotEmpty;
                        if (!isNetwork) {
                          if (widget.mode == MODE_NEW ||
                              widget.mode == MODE_NEW_BARCODE ||
                              widget.mode == MODE_NEW_SHELF ||
                              (widget.mode == MODE_EDIT &&
                                  _coverImage !=
                                      widget.bookRecord!.coverImage)) {
                            newPath = await saveCoverImage(
                                _coverImage!, _txtTitle.text);
                            // .then((value) => newPath = value);
                            if (context.mounted) {
                              if (newPath == "") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Unable to save image! Please take a new photo and try again.")));
                                return;
                              } else {
                                _coverImage = newPath;
                              }
                            }
                          }
                        }
                      }
                      if (context.mounted) {
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
                            coverImage: _coverImage,
                            tags: _bookTags);

                        if (widget.mode == MODE_NEW_SHELF) {
                          //* If New Shelf, return details
                          Navigator.pop(
                              context, {"book": data, "shelf": shelf});
                        } else {
                          //* Else, save to database
                          bool realmSuccess = ModelHelper.addNewBook(
                              data, shelf,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
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

  Widget tagSelectionDialog(tagFormKey, {required List<Tag> bookTags}) {
    // final searchCtrl = TextEditingController();
    List<Map<String, Object>> tagList = generateTagSelection(bookTags);

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => AlertDialog(
                title: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Expanded(child: SearchBar(controller: searchCtrl)),
                      const Expanded(
                          child: Text(
                        "Select Book Tags",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      )),
                      IconButton(
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) => addTagDialog(
                                  context, tagFormKey,
                                  onComplete: () => setState(() => tagList =
                                      generateTagSelection(bookTags)))),
                          icon: const Icon(
                            Icons.add_circle_rounded,
                            color: Colors.white,
                            size: 50,
                          ))
                    ],
                  ),
                ),
                titlePadding: const EdgeInsets.all(0),
                actionsPadding: const EdgeInsets.all(10),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      itemCount: tagList.length,
                      itemBuilder: (context, index) {
                        Tag tag = tagList[index]["Tag"] as Tag;
                        return CheckboxListTile(
                            value: tagList[index]["Value"] as bool,
                            title: Text(tag.tagDesc!),
                            onChanged: (val) => setState(() {
                                  tagList[index]["Value"] = val!;
                                }));
                      }),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                      onPressed: () {
                        List<Tag> selection = [];
                        for (var element in tagList) {
                          if (element["Value"] as bool) {
                            selection.add(element["Tag"] as Tag);
                          }
                        }
                        Navigator.pop(context, selection);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Tags Updated"),
                          showCloseIcon: true,
                          duration: Duration(seconds: 1),
                        ));
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ))
                ]));
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

Widget addTagDialog(context, formKey, {onComplete}) {
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

generateTagSelection(List<Tag> bookTags) {
  RealmResults<Tag> tagData = ModelHelper.getAllTags();
  List<Tag> tagList = ModelHelper.convertToTag(dataFromResults: tagData);
  List<Map<String, Object>> list = [];
  for (Tag x in tagList) {
    Tag? existing =
        bookTags.where((element) => element.tagId == x.tagId).firstOrNull;
    list.add({"Tag": x, "Value": (existing != null)});
  }
  return list;
}

getImageDisplay(String imgPath) {
  bool isNetwork = Uri.parse(imgPath).host.isNotEmpty;

  return (isNetwork)
      ? Image.network(
          imgPath,
          height: 140,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
              alignment: Alignment.center,
              height: 140,
              child: const Stack(
                children: [
                  Placeholder(),
                  Center(
                    child: Text(
                      "Unable to load image",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )),
        )
      : Image.file(
          File(imgPath),
          height: 140,
          errorBuilder: (context, error, stackTrace) => Container(
              alignment: Alignment.center,
              height: 140,
              child: const Stack(
                children: [
                  Placeholder(),
                  Center(
                    child: Text(
                      "Unable to load image",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              )),
        );
}

Future<String> saveCoverImage(String coverImage, String title) async {
  String newPath = "";
  try {
    Directory? externalDir = await getExternalStorageDirectory();
    newPath = path.join(externalDir!.path, path.basename(coverImage));
    File sourceFile = File(coverImage);
    await sourceFile.copy(newPath);
    await sourceFile.delete();
  } catch (e) {
    debugPrint("ERROR: ${e.toString()}");
    newPath = "";
  }
  return newPath;
}
