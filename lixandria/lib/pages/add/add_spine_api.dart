import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:lixandria/models/book_segment.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';
import 'package:lixandria/widgets/customTextfield.dart';
import 'package:http/http.dart';

import '../../widgets/customAlertDialog.dart';
import 'add_spine_book.dart';

class SpineAddApi extends StatefulWidget {
  final String? apiUrl;
  final String? imagePath;
  final String? orientation;
  const SpineAddApi(
      {super.key,
      required this.apiUrl,
      required this.imagePath,
      required this.orientation});

  @override
  State<SpineAddApi> createState() => _SpineAddApiState();
}

class _SpineAddApiState extends State<SpineAddApi> {
  late Future<List<BookSegment>> segmentResults;
  List<String> spineText = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    segmentResults = processShelfImage(
        widget.apiUrl!, widget.imagePath!, widget.orientation!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookSegment>>(
      future: segmentResults,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, TextEditingController> textEditingControllers = {};

          for (int i = 0; i < snapshot.data!.length; i++) {
            // spineText.add(snapshot.data![i].spineText!);
            var textEditingController =
                TextEditingController(text: snapshot.data![i].spineText);
            textEditingControllers.putIfAbsent(
                i.toString(), () => textEditingController);
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
            body: Form(
              key: _formKey,
              child: (snapshot.data!.isEmpty)
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "No book spines found in the image. Please take another photo.",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Slidable(
                                endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) => showDialog(
                                            context: context,
                                            builder: (context) =>
                                                CustomAlertDialog(
                                                    context,
                                                    "Remove book?",
                                                    "Would you like to remove this book spine?",
                                                    confirmOnPressed: () {
                                                  Navigator.of(context).pop();
                                                  setState(() {
                                                    for (int i = 0;
                                                        i <
                                                            snapshot
                                                                .data!.length;
                                                        i++) {
                                                      snapshot.data![i]
                                                              .spineText =
                                                          textEditingControllers[
                                                                  i.toString()]!
                                                              .text;
                                                    }
                                                  });

                                                  snapshot.data!
                                                      .removeAt(index);
                                                  textEditingControllers
                                                      .remove(index.toString());
                                                })),
                                        icon: Icons.delete_rounded,
                                        label: "Delete",
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                      )
                                    ]),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 8.0, 8.0, 0),
                                    child: Image.memory(base64Decode(
                                        snapshot.data![index].imgBuffer!)),
                                  ),
                                  subtitle: CustomTextField(
                                      textEditingControllers[index.toString()]!,
                                      "Detected Spine Text",
                                      isMultiline: true,
                                      errorMsg: "Text cannot be empty!"),
                                ),
                              );
                            },
                          ),
                        ),
                        CustomElevatedButton("Submit", onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            spineText = [];
                            for (int i = 0; i < snapshot.data!.length; i++) {
                              spineText.add(
                                  textEditingControllers[i.toString()]!.text);
                            }
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SpineBookDisplay(spineText: spineText)));
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text("Detected Spine Text cannot be empty!"),
                              showCloseIcon: true,
                            ));
                          }
                        })
                      ],
                    ),
            ),
          );
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
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "An error has occurred: ${snapshot.error.toString()}",
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ));
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
}

Future<List<BookSegment>> processShelfImage(
    String url, String imagePath, String orientation) async {
  // final response = await http.get(Uri.parse(url));
  MultipartRequest request = MultipartRequest('POST', Uri.parse(url));
  request.fields.putIfAbsent("orientation", () => orientation);
  request.files.add(
    await MultipartFile.fromPath('image', imagePath
        // contentType:  MediaType('application', 'jpeg')/,
        ),
  );
  StreamedResponse response = await request.send();
  var apiOutput = await response.stream.bytesToString();
  // var apiOutput = await http.Response.fromStream(response);

  if (response.statusCode == 200) {
    return BookSegment.decodeFromJson(apiOutput);
  } else {
    print("ERROR: ${response.statusCode}");
    throw Exception("Failed to get response");
  }
}
