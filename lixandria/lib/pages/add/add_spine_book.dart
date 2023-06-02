import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lixandria/pages/add/add_manual.dart';
import 'package:lixandria/widgets/customElevatedButton.dart';
import 'package:realm/realm.dart';

import '../../constants.dart';
import '../../models/book.dart';
import '../../models/model_helper.dart';
import 'package:http/http.dart' as http;

class SpineBookDisplay extends StatefulWidget {
  const SpineBookDisplay({super.key});

  @override
  State<SpineBookDisplay> createState() => _SpineBookDisplayState();
}

class _SpineBookDisplayState extends State<SpineBookDisplay> {
  late Future<List<Book>> booksFromAPI;

  @override
  void initState() {
    super.initState();
    booksFromAPI = fetchBookData("");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: booksFromAPI,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
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
                                    setState(() {
                                      snapshot.data!.removeAt(index);
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text("Removal")));
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
                            subtitle: Text(snapshot.data![index].author!),
                            leading: Container(
                              width: 50,
                              child: Image.network(
                                snapshot.data![index].coverImage!,
                                height: 140,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_rounded),
                              ),
                            ),
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AddManual(
                                          bookRecord: snapshot.data![index],
                                          shelfId: "-1",
                                          mode: MODE_NEW_SHELF,
                                        ))),
                          )),
                      separatorBuilder: (context, index) => Divider(),
                    ),
                  ),
                  CustomElevatedButton("Save All",
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content: Text("Saving all books to database")))),
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

  Future<List<Book>> fetchBookData(String spineText) async {
    List<Book> list = [];
    list.add(Book(ObjectId().toString(),
        title: "Test",
        subTitle: "",
        bookRating: 3,
        description: "",
        isRead: false,
        isbnCode: "",
        location: "",
        ownershipStatus: "Owned",
        publisher: "",
        seriesNumber: 0,
        tags: [],
        userNotes: "",
        coverImage:
            "https://d1csarkz8obe9u.cloudfront.net/posterpreviews/contemporary-fiction-night-time-book-cover-design-template-1be47835c3058eb42211574e0c4ed8bf_screen.jpg?ts=1637012564",
        author: "MR X"));

    list.add(Book(ObjectId().toString(),
        title: "Fortress Blood",
        subTitle: "",
        bookRating: 3,
        description: "",
        isRead: false,
        isbnCode: "",
        location: "",
        ownershipStatus: "Owned",
        publisher: "",
        seriesNumber: 0,
        tags: [],
        userNotes: "",
        coverImage:
            "https://www.google.com/url?sa=i&url=https%3A%2F%2Fmiblart.com%2Fblog%2Ffiction-book-cover-design%2F&psig=AOvVaw1J1hVhSMETo_zOk4paTE_9&ust=1685807813182000&source=images&cd=vfe&ved=0CBEQjRxqFwoTCOig_tD5pP8CFQAAAAAdAAAAABAZ",
        author: "L.D Geoffigan"));
    return list;

    // final response = await http.get(
    //     Uri.parse("https://www.googleapis.com/books/v1/volumes?q=$spineText"));

    // if (response.statusCode == 200) {
    //   // If the server did return a 200 OK response,
    //   // then parse the JSON.
    //   return ModelHelper.decodeBookFromJson(response.body);
    // } else {
    //   // If the server did not return a 200 OK response,
    //   // then throw an exception.
    //   throw Exception('Failed to find book');
    // }
  }
}
