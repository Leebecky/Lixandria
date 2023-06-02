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
          children: List.generate(
              shelvesList.length,
              (index) => SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 330,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 8.0),
                        child: ListView.builder(
                          itemCount: shelvesList[index].booksOnShelf.length,
                          scrollDirection: Axis.horizontal,
                          itemExtent: MediaQuery.of(context).size.width / 2.5,
                          itemBuilder: (context, item) {
                            var shelf = shelvesList[index].booksOnShelf;
                            return Container(
                                margin: EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
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
                                                ))),
                                    child: Column(children: [
                                      (shelf[item].coverImage == null)
                                          ? const Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Placeholder(
                                                  fallbackHeight: 140,
                                                ),
                                                Center(
                                                  child: Text(
                                                      "No image provided",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                )
                                              ],
                                            )
                                          : Image.network(
                                              shelf[item].coverImage!,
                                              height: 140,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
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
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
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
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                      // Image(
                                      //     image: NetworkImage(
                                      //         shelf[item].coverImage!),
                                      //     height: 140,
                                      //     loadingBuilder: (context, child,
                                      //             loadingProgress) =>
                                      //         const Padding(
                                      //       padding: EdgeInsets.symmetric(
                                      //           vertical: 52.0),
                                      //       child:
                                      //           CircularProgressIndicator(
                                      //         color: Colors.white,
                                      //       ),
                                      //     ),
                                      // errorBuilder: (context, error,
                                      //         stackTrace) =>
                                      //     Container(
                                      //   alignment: Alignment.center,
                                      //   height: 140,
                                      //   child: const Stack(
                                      //     children: [
                                      //       Placeholder(),
                                      //       Center(
                                      //         child: Text(
                                      //           "Unable to load image",
                                      //           style: TextStyle(
                                      //               color:
                                      //                   Colors.white),
                                      //         ),
                                      //       )
                                      //     ],
                                      //   ),
                                      // ),
                                      //   ),
                                      const Divider(
                                        color: Colors.white,
                                      ),
                                      Text(
                                        shelf[item].title!,
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.white),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(shelf[item].author!,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis)
                                    ]),
                                  ),
                                ));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 8),
                        child: Text(
                          shelvesList[index].shelfName!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ],
                  )))),
    );
  }
}
