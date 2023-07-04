/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: tag.dart
Description: Model for tag class. Used to autogenerate Realm files
First Written On: 02/06/2023
Last Edited On:  08/06/2023
 */

import 'package:realm/realm.dart';

part 'tag.g.dart';

@RealmModel()
class $Tag {
  @PrimaryKey()
  late String tagId;
  late String? tagDesc;
  @Ignored()
  bool isInDatabase = true; // For internal usage only
}
