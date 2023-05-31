// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class Tag extends $Tag with RealmEntity, RealmObjectBase, RealmObject {
  Tag(
    String tagId, {
    String? tagDesc,
  }) {
    RealmObjectBase.set(this, 'tagId', tagId);
    RealmObjectBase.set(this, 'tagDesc', tagDesc);
  }

  Tag._();

  @override
  String get tagId => RealmObjectBase.get<String>(this, 'tagId') as String;
  @override
  set tagId(String value) => RealmObjectBase.set(this, 'tagId', value);

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
      SchemaProperty('tagId', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('tagDesc', RealmPropertyType.string, optional: true),
    ]);
  }
}
