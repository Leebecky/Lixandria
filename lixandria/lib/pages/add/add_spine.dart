import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../../models/book.dart';
import '../../models/model_helper.dart';
import 'add_manual.dart';

class AddSpine extends StatefulWidget {
  final String? ipAddress;
  const AddSpine({super.key, this.ipAddress});

  @override
  State<AddSpine> createState() => _AddSpineState();
}

class _AddSpineState extends State<AddSpine> {
  late Future<List<Book>> booksFromAPI;

  @override
  void initState() {
    super.initState();
    // booksFromAPI = fetchBookData("");
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<List<Book>>(
    //   future: booksFromAPI,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       // return Text(snapshot.data!.first.title!);
    //       return Placeholder();
    //     } else if (snapshot.hasError) {
    //       return Text('${snapshot.error}');
    //     }

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
        body: Center(
          child: Text(widget.ipAddress!),
          //     child: CircularProgressIndicator(
          //   strokeWidth: 8.0,
          // )
        ));
    // },
    // );
    // }
  }

  Future<List<Book>> fetchBookData(String spineText) async {
    final response = await http.get(
        Uri.parse("https://www.googleapis.com/books/v1/volumes?q=$spineText"));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return ModelHelper.decodeBookFromJson(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to find book');
    }
  }
}
