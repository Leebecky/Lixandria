// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Book extends $Book with RealmEntity, RealmObjectBase, RealmObject {
  Book(
    String bookId, {
    String? title,
    String? subTitle,
    String? author,
    String? publisher,
    String? description,
    String? userNotes,
    String? location,
    String? ownershipStatus,
    double? bookRating,
    bool? isRead,
    int? seriesNumber,
    String? coverImage,
    String? isbnCode,
    Iterable<Tag> tags = const [],
  }) {
    RealmObjectBase.set(this, 'bookId', bookId);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'subTitle', subTitle);
    RealmObjectBase.set(this, 'author', author);
    RealmObjectBase.set(this, 'publisher', publisher);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'userNotes', userNotes);
    RealmObjectBase.set(this, 'location', location);
    RealmObjectBase.set(this, 'ownershipStatus', ownershipStatus);
    RealmObjectBase.set(this, 'bookRating', bookRating);
    RealmObjectBase.set(this, 'isRead', isRead);
    RealmObjectBase.set(this, 'seriesNumber', seriesNumber);
    RealmObjectBase.set(this, 'coverImage', coverImage);
    RealmObjectBase.set(this, 'isbnCode', isbnCode);
    RealmObjectBase.set<RealmList<Tag>>(this, 'tags', RealmList<Tag>(tags));
  }

  Book._();

  @override
  String get bookId => RealmObjectBase.get<String>(this, 'bookId') as String;
  @override
  set bookId(String value) => RealmObjectBase.set(this, 'bookId', value);

  @override
  String? get title => RealmObjectBase.get<String>(this, 'title') as String?;
  @override
  set title(String? value) => RealmObjectBase.set(this, 'title', value);

  @override
  String? get subTitle =>
      RealmObjectBase.get<String>(this, 'subTitle') as String?;
  @override
  set subTitle(String? value) => RealmObjectBase.set(this, 'subTitle', value);

  @override
  String? get author => RealmObjectBase.get<String>(this, 'author') as String?;
  @override
  set author(String? value) => RealmObjectBase.set(this, 'author', value);

  @override
  String? get publisher =>
      RealmObjectBase.get<String>(this, 'publisher') as String?;
  @override
  set publisher(String? value) => RealmObjectBase.set(this, 'publisher', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get userNotes =>
      RealmObjectBase.get<String>(this, 'userNotes') as String?;
  @override
  set userNotes(String? value) => RealmObjectBase.set(this, 'userNotes', value);

  @override
  String? get location =>
      RealmObjectBase.get<String>(this, 'location') as String?;
  @override
  set location(String? value) => RealmObjectBase.set(this, 'location', value);

  @override
  String? get ownershipStatus =>
      RealmObjectBase.get<String>(this, 'ownershipStatus') as String?;
  @override
  set ownershipStatus(String? value) =>
      RealmObjectBase.set(this, 'ownershipStatus', value);

  @override
  double? get bookRating =>
      RealmObjectBase.get<double>(this, 'bookRating') as double?;
  @override
  set bookRating(double? value) =>
      RealmObjectBase.set(this, 'bookRating', value);

  @override
  bool? get isRead => RealmObjectBase.get<bool>(this, 'isRead') as bool?;
  @override
  set isRead(bool? value) => RealmObjectBase.set(this, 'isRead', value);

  @override
  int? get seriesNumber =>
      RealmObjectBase.get<int>(this, 'seriesNumber') as int?;
  @override
  set seriesNumber(int? value) =>
      RealmObjectBase.set(this, 'seriesNumber', value);

  @override
  String? get coverImage =>
      RealmObjectBase.get<String>(this, 'coverImage') as String?;
  @override
  set coverImage(String? value) =>
      RealmObjectBase.set(this, 'coverImage', value);

  @override
  RealmList<Tag> get tags =>
      RealmObjectBase.get<Tag>(this, 'tags') as RealmList<Tag>;
  @override
  set tags(covariant RealmList<Tag> value) => throw RealmUnsupportedSetError();

  @override
  String? get isbnCode =>
      RealmObjectBase.get<String>(this, 'isbnCode') as String?;
  @override
  set isbnCode(String? value) => RealmObjectBase.set(this, 'isbnCode', value);

  @override
  Stream<RealmObjectChanges<Book>> get changes =>
      RealmObjectBase.getChanges<Book>(this);

  @override
  Book freeze() => RealmObjectBase.freezeObject<Book>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Book._);
    return const SchemaObject(ObjectType.realmObject, Book, 'Book', [
      SchemaProperty('bookId', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('title', RealmPropertyType.string, optional: true),
      SchemaProperty('subTitle', RealmPropertyType.string, optional: true),
      SchemaProperty('author', RealmPropertyType.string, optional: true),
      SchemaProperty('publisher', RealmPropertyType.string, optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('userNotes', RealmPropertyType.string, optional: true),
      SchemaProperty('location', RealmPropertyType.string, optional: true),
      SchemaProperty('ownershipStatus', RealmPropertyType.string,
          optional: true),
      SchemaProperty('bookRating', RealmPropertyType.double, optional: true),
      SchemaProperty('isRead', RealmPropertyType.bool, optional: true),
      SchemaProperty('seriesNumber', RealmPropertyType.int, optional: true),
      SchemaProperty('coverImage', RealmPropertyType.string, optional: true),
      SchemaProperty('tags', RealmPropertyType.object,
          linkTarget: 'Tag', collectionType: RealmCollectionType.list),
      SchemaProperty('isbnCode', RealmPropertyType.string, optional: true),
    ]);
  }
}
