import 'package:realm/realm.dart';

import 'book.dart';
import 'shelf.dart';
import 'tag.dart';

class ModelHelper {
  // Get all shelves from database
  static RealmResults<Shelf> getAllShelves() {
    final realmConfig =
        Configuration.local([Shelf.schema, Book.schema, Tag.schema]);
    var realm = Realm(realmConfig);

    final RealmResults<Shelf> shelfList = realm.all<Shelf>();

    // if (!realm.isClosed) {
    //   realm.close();
    // }

    return shelfList;
  }

  static List<Shelf> convertToShelf(RealmResults<Shelf> data) {
    List<Shelf> shelves = data
        .map((e) => Shelf(e.shelfId,
            shelfName: e.shelfName,
            booksOnShelf: convertToBook(e.booksOnShelf)))
        .toList();

    return shelves;
  }

  static List<Book> convertToBook(RealmList<Book> data) {
    List<Book> books = data
        .map((b) => Book(b.bookId,
            title: b.title,
            subTitle: b.subTitle,
            author: b.author,
            publisher: b.publisher,
            description: b.description,
            userNotes: b.userNotes,
            location: b.location,
            bookRating: b.bookRating,
            coverImage: b.coverImage,
            isRead: b.isRead,
            isbnCode: b.isbnCode,
            ownershipStatus: b.ownershipStatus,
            seriesNumber: b.seriesNumber,
            tags: convertToTag(b.tags)))
        .toList();
    return books;
  }

  static List<Tag> convertToTag(RealmList<Tag> data) {
    List<Tag> tags = data.map((t) => Tag(t.tagId, tagDesc: t.tagDesc)).toList();
    return tags;
  }

  // Save new book record
  static bool addNewBook(Book data, String shelfId,
      {String? oldShelfId, bool isUpdate = false}) {
    final realmConfig =
        Configuration.local([Shelf.schema, Book.schema, Tag.schema]);
    var realm = Realm(realmConfig);

    final shelf = realm.all<Shelf>().query(r'shelfId == $0', [shelfId]);

    realm.write(() {
      realm.add(data, update: isUpdate);

      if (!isUpdate || (isUpdate && (shelfId != oldShelfId))) {
        if (shelf.isNotEmpty) {
          shelf[0].booksOnShelf.add(data);
        }
      }

      if (isUpdate && (shelfId != oldShelfId)) {
        final oldShelf =
            realm.all<Shelf>().query(r'shelfId == $0', [oldShelfId!]);
        int recordIndex = oldShelf[0]
            .booksOnShelf
            .indexWhere((element) => element.bookId == data.bookId);
        oldShelf[0].booksOnShelf.removeAt(recordIndex);
      }
    });

    // if (!realm.isClosed) {
    //   realm.close();
    // }
    return true;
  }

  static bool deleteBook(String bookId) {
    final realmConfig =
        Configuration.local([Shelf.schema, Book.schema, Tag.schema]);
    var realm = Realm(realmConfig);
    try {
      final bookFromDb =
          realm.all<Book>().query(r'bookId == $0', [bookId]).first;
      realm.write(() {
        realm.delete(bookFromDb);
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
