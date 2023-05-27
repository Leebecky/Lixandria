// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Tag extends $Tag with RealmEntity, RealmObjectBase, RealmObject {
  Tag(
    ObjectId tagId, {
    String? tagDesc,
  }) {
    RealmObjectBase.set(this, 'tagId', tagId);
    RealmObjectBase.set(this, 'tagDesc', tagDesc);
  }

  Tag._();

  @override
  ObjectId get tagId =>
      RealmObjectBase.get<ObjectId>(this, 'tagId') as ObjectId;
  @override
  set tagId(ObjectId value) => RealmObjectBase.set(this, 'tagId', value);

  @override
  String? get tagDesc =>
      RealmObjectBase.get<String>(this, 'tagDesc') as String?;
  @override
  set tagDesc(String? value) => RealmObjectBase.set(this, 'tagDesc', value);

  @override
  Stream<RealmObjectChanges<Tag>> get changes =>
      RealmObjectBase.getChanges<Tag>(this);

  @override
  Tag freeze() => RealmObjectBase.freezeObject<Tag>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Tag._);
    return const SchemaObject(ObjectType.realmObject, Tag, 'Tag', [
      SchemaProperty('tagId', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('tagDesc', RealmPropertyType.string, optional: true),
    ]);
  }
}
