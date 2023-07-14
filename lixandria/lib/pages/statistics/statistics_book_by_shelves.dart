/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: statistics_book_by_shelves.dart
Description: UI Page. Displays the books by shelves chart and handles relevant business logic.
First Written On: 18/06/2023
Last Edited On:  23/06/2023
 */

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lixandria/models/model_helper.dart';

import '../../models/shelf.dart';

class BooksByShelves extends StatefulWidget {
  const BooksByShelves({super.key});

  final Color barBackgroundColor = const Color(0xff484357);
  final Color barColor = Colors.white;
  final Color touchedBarColor = Colors.green;
  @override
  State<BooksByShelves> createState() => _BooksByShelvesState();
}

class _BooksByShelvesState extends State<BooksByShelves> {
  int touchedIndex = -1;
  List<Shelf> shelfData = [];
  List<String?> shelfNames = [];
  double maxY = 0;
  double intervalVal = 1;
  @override
  void initState() {
    super.initState();
    shelfData = ModelHelper.convertToShelf(ModelHelper.getAllShelves());
    shelfNames = shelfData.map((e) => e.shelfName).toList();
    for (var x in shelfData) {
      maxY = (x.booksOnShelf.length.toDouble() > maxY)
          ? x.booksOnShelf.length.toDouble()
          : maxY;
    }

    switch (maxY) {
      case <= 10:
        intervalVal = 1;
        break;
      case <= 15:
        intervalVal = 5;
        break;
      case < 40:
        intervalVal = 10;
        break;
      default:
        1;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Books by Shelves",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const SizedBox(
              height: 25,
            ),
            (shelfData.isEmpty)
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
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2),
                          borderRadius: BorderRadius.circular(15)),
                      width: (shelfData.length < 4)
                          ? MediaQuery.of(context).size.width * 0.95
                          : shelfData.length *
                              (MediaQuery.of(context).size.width / 4),
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: BarChart(mainBarData()),
                    ),
                  ),
            const SizedBox(
              height: 60,
            )
          ]),
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceEvenly,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            tooltipHorizontalAlignment: FLHorizontalAlignment.right,
            tooltipMargin: -10,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              (shelfNames.isNotEmpty)
                  ? weekDay = shelfNames[group.x]!
                  : throw Error();

              return BarTooltipItem(
                //Tooltip
                '$weekDay\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: (rod.toY - 1).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ))
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      //* Config for axis spacing
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true, reservedSize: 35, interval: intervalVal),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

//* Bar generator
  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= widget.barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? widget.touchedBarColor : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: Colors.green.shade700)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: maxY,
            color: widget.barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  //* From Data => generate bars
  List<BarChartGroupData> showingGroups() {
    List<BarChartGroupData> data = [];
    for (int i = 0; i < shelfData.length; i++) {
      data.add(makeGroupData(i, shelfData[i].booksOnShelf.length.toDouble(),
          isTouched: i == touchedIndex));
    }
    return data;
  }

//* x-axis title data
  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text =
        (shelfNames[value.toInt()] != null) ? shelfNames[value.toInt()]! : "";
    Widget titleWidget = Text(text, style: style);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: titleWidget,
    );
  }
}
