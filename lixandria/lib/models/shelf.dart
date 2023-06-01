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
