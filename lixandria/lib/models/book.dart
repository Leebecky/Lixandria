import 'dart:ffi';

import 'package:googleapis/driveactivity/v2.dart';
import 'package:lixandria/models/tag.dart';
import 'package:realm/realm.dart';

part 'book.g.dart';

@RealmModel()
class $Book {
  @PrimaryKey()
  late String bookId;

  late String? title;
  late String? subTitle;
  late String? author;
  late String? publisher;
  late String? description;
  late String? userNotes;
  late String? location;
  late String? ownershipStatus;
  late double? bookRating;
  late bool? isRead;
  late int? seriesNumber;
  late String? coverImage;
  late List<$Tag> tags = [];
  late String? isbnCode;
}
