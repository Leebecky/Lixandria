// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Shelf extends _Shelf with RealmEntity, RealmObjectBase, RealmObject {
  Shelf(
    ObjectId shelfId, {
    String? shelfName,
    Iterable<Book> booksOnShelf = const [],
  }) {
    RealmObjectBase.set(this, 'shelfId', shelfId);
    RealmObjectBase.set(this, 'shelfName', shelfName);
    RealmObjectBase.set<RealmList<Book>>(
        this, 'booksOnShelf', RealmList<Book>(booksOnShelf));
  }

  Shelf._();

  @override
  ObjectId get shelfId =>
      RealmObjectBase.get<ObjectId>(this, 'shelfId') as ObjectId;
  @override
  set shelfId(ObjectId value) => RealmObjectBase.set(this, 'shelfId', value);

  @override
  String? get shelfName =>
      RealmObjectBase.get<String>(this, 'shelfName') as String?;
  @override
  set shelfName(String? value) => RealmObjectBase.set(this, 'shelfName', value);

  @override
  RealmList<Book> get booksOnShelf =>
      RealmObjectBase.get<Book>(this, 'booksOnShelf') as RealmList<Book>;
  @override
  set booksOnShelf(covariant RealmList<Book> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Shelf>> get changes =>
      RealmObjectBase.getChanges<Shelf>(this);

  @override
  Shelf freeze() => RealmObjectBase.freezeObject<Shelf>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Shelf._);
    return const SchemaObject(ObjectType.realmObject, Shelf, 'Shelf', [
      SchemaProperty('shelfId', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('shelfName', RealmPropertyType.string, optional: true),
      SchemaProperty('booksOnShelf', RealmPropertyType.object,
          linkTarget: 'Book', collectionType: RealmCollectionType.list),
    ]);
  }
}
