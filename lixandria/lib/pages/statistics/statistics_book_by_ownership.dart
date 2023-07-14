/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: statistics_book_by_ownership.dart
Description: UI Page. Displays the books by ownership chart and handles relevant business logic.
First Written On: 18/06/2023
Last Edited On:  23/06/2023
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lixandria/constants.dart';
import 'package:lixandria/models/model_helper.dart';
import '../../models/book.dart';

class BooksByOwnership extends StatefulWidget {
  const BooksByOwnership({super.key});
  final Color barBackgroundColor = const Color(0xff484357);
  final Color barColor = Colors.white;
  final Color touchedBarColor = Colors.green;

  @override
  State<BooksByOwnership> createState() => _BooksByOwnershipState();
}

class _BooksByOwnershipState extends State<BooksByOwnership> {
  int touchedIndex = -1;

  final List<Color> colourSet = [
    Colors.teal,
    Colors.purple.shade700,
    Colors.blue.shade700
  ];

  final List<String> ownershipSet = OWNERSHIP_SET;
  List<PieData> dataset = [];
  int totalBooks = 0;

  @override
  void initState() {
    super.initState();
    List<Book> bookList = ModelHelper.getAllBooks();
    if (bookList.isNotEmpty) {
      for (int i = 0; i < ownershipSet.length; i++) {
        List<Book?> ownershipBooks = bookList
            .where((x) => x.ownershipStatus == ownershipSet[i])
            .toList();
        int val = ownershipBooks.length;

        dataset.add(PieData(
            sliceColour: colourSet[i],
            sliceValue: val,
            slicePercentage: ((val / bookList.length) * 100).toStringAsFixed(2),
            sliceLabel: ownershipSet[i]));
      }
      totalBooks = bookList.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              "Books by Ownership",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.5,
              child: (dataset.isEmpty)
                  ? Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      padding: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2),
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      child: const Center(
                        child: Text(
                          "No data available",
                          style: TextStyle(fontSize: 20),
                        ),
                      ))
                  : Stack(children: [
                      LayoutBuilder(builder: (context, constraints) {
                        final radius = constraints.biggest.shortestSide / 2.5;
                        return PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 0,
                            centerSpaceRadius: 0,
                            sections: showingSections(radius, totalBooks),
                          ),
                        );
                      }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                                dataset.length,
                                (index) => Indicator(
                                    legendText: dataset[index].pieSliceLabel,
                                    iconColour: dataset[index].pieSliceColour))
                            .toList(),
                      ),
                    ]),
            )
          ]),
    );
  }

  List<PieChartSectionData> showingSections(radius, int totalBooks) {
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    return List.generate(dataset.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final sliceRadius = isTouched ? radius + 10 : radius;

      return PieChartSectionData(
        color: dataset[i].pieSliceColour,
        value: (dataset[i].pieSliceValue / totalBooks) * 360,
        title:
            "${dataset[i].pieSlicePercentage}%\n(${dataset[i].pieSliceValue})",
        radius: sliceRadius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
}

Widget Indicator({
  String legendText = "Legend",
  Color legendColour = Colors.black,
  Color iconColour = Colors.white,
}) {
  return Row(children: [
    Icon(
      Icons.square,
      color: iconColour,
    ),
    Text(
      legendText,
      style: TextStyle(fontWeight: FontWeight.bold, color: legendColour),
    )
  ]);
}

class PieData {
  late Color pieSliceColour;
  late int pieSliceValue;
  late Color pieTextColour;
  late String pieSliceLabel;
  late String pieSlicePercentage;

  PieData(
      {required Color sliceColour,
      required int sliceValue,
      required String sliceLabel,
      String slicePercentage = "0",
      Color textColour = Colors.white}) {
    pieSliceColour = sliceColour;
    pieSliceValue = sliceValue;
    pieSliceLabel = sliceLabel;
    pieSlicePercentage = slicePercentage;
    pieTextColour = textColour;
  }
}
