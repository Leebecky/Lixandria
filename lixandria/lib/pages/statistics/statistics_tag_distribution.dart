/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: statistics_tag_distribution.dart
Description: UI Page. Displays the tags distribution chart and handles relevant business logic.
First Written On: 18/06/2023
Last Edited On:  23/06/2023
 */

import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:lixandria/models/model_helper.dart';
import 'dart:math' as math;
import '../../models/book.dart';
import '../../models/tag.dart';

class TagWordcloud extends StatefulWidget {
  const TagWordcloud({super.key});

  @override
  State<TagWordcloud> createState() => _TagWordcloudState();
}

class _TagWordcloudState extends State<TagWordcloud> {
  List<Tag> tagList = [];
  List<Word> wordList = [];

  @override
  void initState() {
    super.initState();
    tagList =
        ModelHelper.convertToTag(dataFromResults: ModelHelper.getAllTags());
    List<Book> bookList = ModelHelper.getAllBooks();
    wordList = Word.generateWords(tagList, bookList);
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                "Tag Usage",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                height: MediaQuery.of(context).size.height / 1.5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (wordList.isEmpty)
                      ? const Center(
                          child: Text("No data available",
                              style: TextStyle(fontSize: 20)))
                      : FittedBox(
                          child: Scatter(
                            delegate:
                                ArchimedeanSpiralScatterDelegate(ratio: ratio),
                            children: List.generate(wordList.length,
                                (index) => ScatterItem(wordList[index], index)),
                          ),
                        ),
                ),
              )
            ]));
  }
}

class ScatterItem extends StatelessWidget {
  ScatterItem(this.word, this.index);
  final Word word;
  final int index;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: 10 * word.size.toDouble(),
      color: word.color,
    );
    return RotatedBox(
      quarterTurns: word.rotated ? 1 : 0,
      child: Text(
        word.text,
        style: style,
      ),
    );
  }
}

class Word {
  const Word(
    this.text,
    this.color,
    this.size,
    this.rotated,
  );
  final String text;
  final Color color;
  final int size;
  final bool rotated;

  static List<Word> generateWords(List<Tag> tagList, List<Book> bookList) {
    List<Word> wordList = [];
    for (Tag tag in tagList) {
      Color randomColour = HSVColor.fromAHSV(
              1.0,
              math.Random().nextDouble() * 360,
              1.0,
              math.Random().nextDouble() * 1)
          .toColor();

      bool randomRotation = math.Random().nextBool();
      List<Book?> list = bookList
          .where((x) =>
              x.tags.where((e) => e.tagId == tag.tagId).firstOrNull != null)
          .toList();
      int val = list.length;

      wordList.add(Word(tag.tagDesc!, randomColour, val, randomRotation));
    }

    return wordList;
  }
}
