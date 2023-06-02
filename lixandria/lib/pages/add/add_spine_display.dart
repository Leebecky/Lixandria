import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lixandria/models/book_segment.dart';
import 'package:lixandria/pages/add/add_barcode.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';
import 'package:lixandria/widgets/customTextfield.dart';

import 'add_spine_book.dart';

class SpineAddDisplay extends StatefulWidget {
  final String? apiUrl;
  final String? imagePath;
  const SpineAddDisplay(
      {super.key, required this.apiUrl, required this.imagePath});

  @override
  State<SpineAddDisplay> createState() => _SpineAddDisplayState();
}

class _SpineAddDisplayState extends State<SpineAddDisplay> {
  late Future<List<BookSegment>> segmentResults;

  @override
  void initState() {
    super.initState();
    segmentResults = processShelfImage(widget.apiUrl!, widget.imagePath!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookSegment>>(
      future: segmentResults,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, TextEditingController> textEditingControllers = {};

          for (int i = 0; i < snapshot.data!.length; i++) {
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
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        endActionPane:
                            ActionPane(motion: ScrollMotion(), children: [
                          SlidableAction(
                            onPressed: (context) =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Delete..."))),
                            icon: Icons.delete_rounded,
                            label: "Delete",
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                          )
                        ]),
                        child: ListTile(
                          title: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                            child: Image.memory(
                                base64Decode(snapshot.data![index].imgBuffer!)),
                          ),
                          subtitle: CustomTextField(
                              textEditingControllers[index.toString()]!,
                              "Detected Spine Text",
                              errorMsg: "Text cannot be empty!"),
                        ),
                      );
                    },
                  ),
                ),
                CustomElevatedButton("Submit", onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SpineBookDisplay()));
                })
              ],
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
                child: Text("An error has occured: ${snapshot.error}"),
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
    String url, String imagePath) async {
  // final response = await http.get(Uri.parse(url));
  http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(url));

  request.files.add(
    await http.MultipartFile.fromPath('image', imagePath
        // contentType: http. MediaType('application', 'jpeg')/,
        ),
  );
  http.StreamedResponse response = await request.send();
  var apiOutput = await response.stream.bytesToString();
  // var apiOutput = await http.Response.fromStream(response);

  if (response.statusCode == 200) {
    return BookSegment.decodeFromJson(apiOutput);
  } else {
    print("ERROR: ${response.statusCode}");
    throw Exception("Failed to get response");
  }
}
