import 'dart:convert';

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

  static RealmResults<Tag> getAllTags() {
    final realmConfig = Configuration.local([Tag.schema]);
    var realm = Realm(realmConfig);

    final RealmResults<Tag> tagList = realm.all<Tag>();
    return tagList;
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
            tags: convertToTag(data: b.tags)))
        .toList();
    return books;
  }

  static List<Tag> convertToTag(
      {RealmList<Tag>? data, RealmResults<Tag>? dataFromResults}) {
    if (data != null) {
      List<Tag> tags =
          data.map((t) => Tag(t.tagId, tagDesc: t.tagDesc)).toList();
      return tags;
    } else {
      List<Tag> tags = dataFromResults!
          .map((t) => Tag(t.tagId, tagDesc: t.tagDesc))
          .toList();
      return tags;
    }
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

  static List<Book> decodeBookFromJson(String apiResponse,
      {int maxResponses = -1}) {
    Map<String, dynamic> json = jsonDecode(apiResponse);
    List<Book> bookList = [];

    int maxLength = (maxResponses == -1) ? json["totalItems"] : maxResponses;

    for (var i = 0; i < maxLength; i++) {
      var bookData = json["items"][i]["volumeInfo"];

      Book book = Book(ObjectId().toString(),
          title: (bookData["title"] != null) ? bookData["title"] : "",
          subTitle: (bookData["subtitle"] != null) ? bookData["subtitle"] : "",
          author: (bookData["authors"] != null)
              ? (bookData["authors"] as List).join(",")
              : "",
          bookRating: 3,
          coverImage: (bookData["imageLinks"] != null)
              ? bookData["imageLinks"]["thumbnail"]
              : "",
          description:
              (bookData["description"] != null) ? bookData["description"] : "",
          isRead: false,
          isbnCode: (bookData["industryIdentifiers"] != null)
              ? bookData["industryIdentifiers"][1]["identifier"]
              : "",
          location: "",
          ownershipStatus: "Owned",
          publisher:
              (bookData["publisher"] != null) ? bookData["publisher"] : "",
          seriesNumber: 0,
          tags: [], // TODO: Handle Tags. Cross check existence in db, if !EXIST, then create new tag.
          userNotes: "");
      bookList.add(book);
    }

    return bookList;
  }

  // add new shelf record
  static addNewShelf(Shelf data, bool isUpdate) {
    try {
      final realmConfig =
          Configuration.local([Shelf.schema, Book.schema, Tag.schema]);
      var realm = Realm(realmConfig);

      realm.write(() {
        realm.add(data, update: isUpdate);
      });
      return true;
    } catch (ex) {
      print("addNewShelf Exception: ${ex.toString()}");
      return false;
    }
  }

  // delete shelf
  static bool deleteShelf(String shelfId) {
    final realmConfig =
        Configuration.local([Shelf.schema, Book.schema, Tag.schema]);
    var realm = Realm(realmConfig);
    try {
      final dataFromDb =
          realm.all<Shelf>().query(r'shelfId == $0', [shelfId]).first;
      realm.write(() {
        realm.delete(dataFromDb);
      });

      return true;
    } catch (e) {
      print("deleteShelf Exception: ${e.toString()}");
      return false;
    }
  }

  // add new Tag record
  static addNewTag(Tag data, bool isUpdate) {
    try {
      final realmConfig = Configuration.local([Tag.schema]);
      var realm = Realm(realmConfig);

      realm.write(() {
        realm.add(data, update: isUpdate);
      });
      return true;
    } catch (ex) {
      print("addNewTag Exception: ${ex.toString()}");
      return false;
    }
  }

  // delete Tag
  static bool deleteTag(String tagId) {
    final realmConfig = Configuration.local([Book.schema, Tag.schema]);
    var realm = Realm(realmConfig);
    try {
      final dataFromDb = realm.all<Tag>().query(r'tagId == $0', [tagId]).first;
      final books = realm.all<Book>();
      List<Tag> deletionList = [];

      for (var book in books) {
        final tagData = book.tags.query(r'tagId == $0', [tagId]).firstOrNull;
        if (tagData != null) {
          deletionList.add(tagData);
        }
      }

      realm.write(() {
        if (deletionList.isNotEmpty) {
          realm.deleteMany(deletionList);
        }
        realm.delete(dataFromDb);
      });

      return true;
    } catch (e) {
      print("deleteTag Exception: ${e.toString()}");
      return false;
    }
  }
}
