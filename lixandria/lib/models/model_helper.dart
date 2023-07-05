/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: model_helper.dart
Description: Helper Class used to interface with the models in the system. Handles all communication with the database.
First Written On: 02/06/2023
Last Edited On:  04/07/2023
 */

import 'dart:convert';

import 'package:lixandria/constants.dart';
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

    final RealmResults<Shelf> shelfList =
        realm.query('TRUEPREDICATE SORT(shelfName ASC)');

    // if (!realm.isClosed) {
    //   realm.close();
    // }

    return shelfList;
  }

  static RealmResults<Tag> getAllTags() {
    final realmConfig = Configuration.local([Tag.schema]);
    var realm = Realm(realmConfig);

    final RealmResults<Tag> tagList =
        realm.query('TRUEPREDICATE SORT(tagDesc ASC)');
    return tagList;
  }

  // Get all shelves from database
  static List<Book> getAllBooks() {
    final realmConfig =
        Configuration.local([Shelf.schema, Book.schema, Tag.schema]);
    var realm = Realm(realmConfig);

    final RealmResults<Book> data = realm.all<Book>();
    List<Book> bookList = data
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

    return bookList;
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
        .toList()
      ..sort(
          (a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()));
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
      realm.add(data, update: true);

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
      {int maxResponses = 1}) {
    Map<String, dynamic> json = jsonDecode(apiResponse);
    List<Tag> tagList =
        ModelHelper.convertToTag(dataFromResults: ModelHelper.getAllTags());
    List<Book> bookList = [];
    int maxLength = (int.parse(json["totalItems"].toString()) < maxResponses)
        ? int.parse(json["totalItems"].toString())
        : maxResponses;

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
              ? (bookData["industryIdentifiers"] as List).length > 1
                  ? bookData["industryIdentifiers"][1]["identifier"]
                  : bookData["industryIdentifiers"][0]["identifier"]
              : "",
          location: "",
          ownershipStatus: OWNERSHIP_OWNED,
          publisher:
              (bookData["publisher"] != null) ? bookData["publisher"] : "",
          seriesNumber: 0,
          tags: (bookData["categories"] != null)
              ? ((bookData["categories"] as List).map((e) {
                  Tag? db = tagList
                      .where((x) =>
                          x.tagDesc!.toLowerCase() ==
                          e.toString().toLowerCase())
                      .firstOrNull;
                  if (db != null) {
                    return db;
                  } else {
                    return Tag(ObjectId().toString(), tagDesc: e)
                      ..isInDatabase = false;
                  }
                }).toList())
              : [],
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

      final List<Shelf> dataFromDb = realm
          .all<Shelf>()
          .query(r'shelfName Contains[c] $0', [data.shelfName!]).toList();

      bool hasMatch = false;

      if (dataFromDb.isNotEmpty) {
        for (var record in dataFromDb) {
          hasMatch = (record.shelfName!.toLowerCase() ==
              data.shelfName!.toLowerCase());
          if (hasMatch) {
            if (isUpdate && record.shelfId == data.shelfId) {
              hasMatch = false;
              break;
            }

            return "This shelf name already exists in the database!";
          }
        }
      }

      if (!hasMatch) {
        realm.write(() {
          realm.add(data, update: isUpdate);
        });
        return "Success";
      }
    } catch (ex) {
      print("addNewShelf Exception: ${ex.toString()}");
      return ex.toString();
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

      final List<Tag> dataFromDb = realm
          .all<Tag>()
          .query(r'tagDesc Contains[c] $0', [data.tagDesc!]).toList();
      bool hasMatch = false;

      if (dataFromDb.isNotEmpty) {
        for (var record in dataFromDb) {
          hasMatch =
              (record.tagDesc!.toLowerCase() == data.tagDesc!.toLowerCase());
          if (hasMatch) {
            if (isUpdate && record.tagId == data.tagId) {
              hasMatch = false;
              break;
            }

            return "This tag already exists in the database!";
          }
        }
      }

      if (!hasMatch) {
        realm.write(() {
          realm.add(data, update: isUpdate);
        });
        return "Success";
      }
    } catch (ex) {
      print("addNewTag Exception: ${ex.toString()}");
      return ex.toString();
    }
  }

  // delete Tag
  static bool deleteTag(String tagId) {
    final realmConfig = Configuration.local([Book.schema, Tag.schema]);
    var realm = Realm(realmConfig);
    try {
      final dataFromDb = realm.all<Tag>().query(r'tagId == $0', [tagId]).first;

      realm.write(() {
        realm.delete(dataFromDb);
      });

      return true;
    } catch (e) {
      print("deleteTag Exception: ${e.toString()}");
      return false;
    }
  }

  static Book generateEmptyBook() {
    return Book(ObjectId().toString(),
        title: "",
        subTitle: "",
        author: "",
        publisher: "",
        description: "",
        userNotes: "",
        location: "",
        bookRating: 0,
        coverImage: "",
        isRead: false,
        isbnCode: "",
        ownershipStatus: "",
        seriesNumber: 0,
        tags: []);
  }
}
