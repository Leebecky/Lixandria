/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: add_barcode.dart
Description: UI Page. Handles the Barcode Scanner and relevant business logic.
First Written On: 12/06/2023
Last Edited On:  18/06/2023
 */

import 'package:flutter/material.dart';
import 'package:lixandria/constants.dart';
import 'package:lixandria/models/model_helper.dart';
import 'package:lixandria/pages/add/add_manual.dart';
import 'package:http/http.dart';

import '../../models/book.dart';

class AddBarcode extends StatefulWidget {
  final String? barcode;
  const AddBarcode({super.key, this.barcode});

  @override
  State<AddBarcode> createState() => _AddBarcodeState();
}

class _AddBarcodeState extends State<AddBarcode> {
  late Future<List<Book>> booksFromAPI;
  // late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    booksFromAPI = fetchBookData(widget.barcode!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: booksFromAPI,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return AddManual(
              mode: MODE_NEW_BARCODE,
              bookRecord: snapshot.data!.first,
              shelfId: "-1",
            );
          } else {
            //* if no book is found
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
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "No book with ISBN: ${widget.barcode} found. \nTry scanning the barcode again or consider using the Manual or Scan Book Spine methods instead.",
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            );
          }
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

Future<List<Book>> fetchBookData(String barcodeScan) async {
  // barcodeScan = "9780786837885";
  final response = await get(Uri.parse(
      "https://www.googleapis.com/books/v1/volumes?q=isbn:$barcodeScan"));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return ModelHelper.decodeBookFromJson(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load book');
  }
}
