import 'dart:ffi';

import 'package:googleapis/driveactivity/v2.dart';
import 'package:realm/realm.dart';

part 'tag.g.dart';

@RealmModel()
class $Tag {
  @PrimaryKey()
  late ObjectId tagId;
  late String? tagDesc;
}
