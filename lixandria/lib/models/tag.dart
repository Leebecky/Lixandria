import 'dart:ffi';

import 'package:googleapis/driveactivity/v2.dart';
import 'package:realm/realm.dart';

part 'tag.g.dart';

@RealmModel()
class $Tag {
  @PrimaryKey()
  late String tagId;
  late String? tagDesc;
}
