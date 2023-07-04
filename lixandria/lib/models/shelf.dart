/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: shelf.dart
Description: Model for shelf class. Used to autogenerate Realm files
First Written On: 02/06/2023
Last Edited On:  08/06/2023
 */

import 'package:realm/realm.dart';
import 'package:lixandria/models/book.dart';

part 'shelf.g.dart';

@RealmModel()
class _Shelf {
  @PrimaryKey()
  late String shelfId;

  late String? shelfName;
  late List<$Book> booksOnShelf = [];
}
