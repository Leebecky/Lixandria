/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: constants.dart
Description: Helper page. Contains all constant values used in the system that are not stored in the database. 
First Written On: 02/06/2023
Last Edited On:  12/06/2023
 */

const String MODE_EDIT = "edit";
const String MODE_NEW = "new";
const String MODE_NEW_BARCODE = "new_barcode ";
const String MODE_NEW_SHELF = "new_book_shelf";

const String OWNERSHIP_OWNED = "Owned";
const String OWNERSHIP_WISHLIST = "Wishlist";
const String OWNERSHIP_BORROWED = "Borrowed";
const List<String> OWNERSHIP_SET = [
  OWNERSHIP_OWNED,
  OWNERSHIP_BORROWED,
  OWNERSHIP_WISHLIST
];

const String ORIENTATION_UPRIGHT = "Vertical";
const String ORIENTATION_SIDEWAYS = "Horizontal";
const List<String> BOOK_ORIENTATION = [
  ORIENTATION_UPRIGHT,
  ORIENTATION_SIDEWAYS
];
