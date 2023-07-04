/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: book_segment.dart
Description: Helper class for handling data returned from the Spine Segmentation and OCR API
First Written On: 12/06/2023
Last Edited On:  18/06/2023
 */

import 'dart:convert';

class BookSegment {
  String? spineText;
  String? imgBuffer;

  BookSegment({this.spineText, this.imgBuffer});

  static BookSegment createBookSegment(String spineText, String imgBuffer) {
    BookSegment bookSegment = BookSegment();
    bookSegment.spineText = spineText;
    bookSegment.imgBuffer = imgBuffer;

    return bookSegment;
  }

  static List<BookSegment> decodeFromJson(String apiResponse) {
    List<BookSegment> list = [];
    var json = jsonDecode(apiResponse);
    for (var i = 0; i < json.length; i++) {
      BookSegment data = BookSegment(
          spineText: json[i]["spine_text"], imgBuffer: json[i]["img"]);

      list.add(data);
    }
    return list;
  }
}
