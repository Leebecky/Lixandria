import 'package:flutter/material.dart';
import 'package:lixandria/models/model_helper.dart';
import 'package:lixandria/pages/add_manual.dart';
import 'package:realm/realm.dart';

import '../constants.dart';
import '../models/book.dart';
import '../models/shelf.dart';
import '../models/tag.dart';

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
                  height: 280,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 8),
                        child: ListView.builder(
                          itemCount: shelvesList[index].booksOnShelf.length,
                          scrollDirection: Axis.horizontal,
                          itemExtent: MediaQuery.of(context).size.width / 3,
                          itemBuilder: (context, item) {
                            var shelf = shelvesList[index].booksOnShelf;
                            return Container(
                                color: const Color(0xff484357),
                                child: Card(
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
                                      const Placeholder(
                                        fallbackHeight: 150,
                                      ),
                                      Text(
                                        shelf[item].title!,
                                        style: const TextStyle(fontSize: 20),
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(shelf[item].author!,
                                          style: const TextStyle(fontSize: 15),
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
