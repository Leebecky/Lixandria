/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: home.dart
Description: UI Page. Displays the home page and relevant business logic.
First Written On: 18/06/2023
Last Edited On:  23/06/2023
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lixandria/models/model_helper.dart';
import 'package:lixandria/pages/add/add_manual.dart';
import 'package:realm/realm.dart';

import '../constants.dart';
import '../models/shelf.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Shelf> shelvesList = [];

  @override
  void initState() {
    super.initState();

    RealmResults<Shelf> shelfData = ModelHelper.getAllShelves();
    shelvesList = ModelHelper.convertToShelf(shelfData);

    // Retrieve from database:
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          //* Shelves
          children: (shelvesList.isEmpty)
              ? [
                  const Center(
                      child: Text(
                    "No shelves in the database",
                    style: TextStyle(fontSize: 20),
                  ))
                ]
              : List.generate(
                  shelvesList.length,
                  (index) => SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 330,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 30.0, horizontal: 8.0),
                            //* Items in shelf
                            child: (shelvesList[index].booksOnShelf.isNotEmpty)
                                ? ListView.builder(
                                    itemCount:
                                        shelvesList[index].booksOnShelf.length,
                                    scrollDirection: Axis.horizontal,
                                    itemExtent:
                                        MediaQuery.of(context).size.width / 2.5,
                                    itemBuilder: (context, item) {
                                      var shelf =
                                          shelvesList[index].booksOnShelf;
                                      return Container(
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            color: const Color(0xff484357),
                                          ),
                                          child: Card(
                                            color: const Color(0xff484357),
                                            child: InkWell(
                                              onTap: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) => AddManual(
                                                  mode: MODE_EDIT,
                                                  bookRecord: shelf[item],
                                                  shelfId: shelvesList[index]
                                                      .shelfId,
                                                ),
                                              )),
                                              child: Column(children: [
                                                (shelf[item].coverImage ==
                                                            null ||
                                                        shelf[item]
                                                                .coverImage ==
                                                            "")
                                                    ? const Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Placeholder(
                                                            fallbackHeight: 140,
                                                          ),
                                                          Center(
                                                              child: Text(
                                                                  "No image provided",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)))
                                                        ],
                                                      )
                                                    : getImageDisplay(
                                                        shelf[item]
                                                            .coverImage!),
                                                const Divider(
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  shelf[item].title!,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(shelf[item].author!,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                    textAlign: TextAlign.center,
                                                    overflow:
                                                        TextOverflow.ellipsis)
                                              ]),
                                            ),
                                          ));
                                    },
                                  )
                                : SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 330,
                                    child: Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: const Color(0xff484357),
                                        ),
                                        child: const Text(
                                          "No books on shelf",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ))),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 5),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 8),
                              child: Text(
                                shelvesList[index].shelfName!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ))
                        ],
                      )))),
    );
  }
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
                  ))
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
                  ))
                ],
              )),
        );
}
