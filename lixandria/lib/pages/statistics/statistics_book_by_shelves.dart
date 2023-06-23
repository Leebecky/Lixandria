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
      case <= 20:
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
            const Text(
              "Books by Shelves",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.5,
              child: BarChart(mainBarData()),
            ),
            const SizedBox(
              height: 80,
            )
          ]),
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            tooltipHorizontalAlignment: FLHorizontalAlignment.right,
            tooltipMargin: -10,
            fitInsideHorizontally: true,
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
    //  List.generate(7, (i) {
    //       switch (i) {
    //         case 0:
    //           return makeGroupData(0, 5, isTouched: i == touchedIndex);
    //         case 1:
    //           return makeGroupData(1, 6.5, isTouched: i == touchedIndex);
    //         case 2:
    //           return makeGroupData(2, 5, isTouched: i == touchedIndex);
    //         case 3:
    //           return makeGroupData(3, 7.5, isTouched: i == touchedIndex);
    //         case 4:
    //           return makeGroupData(4, 9, isTouched: i == touchedIndex);
    //         case 5:
    //           return makeGroupData(5, 11.5, isTouched: i == touchedIndex);
    //         case 6:
    //           return makeGroupData(6, 6.5, isTouched: i == touchedIndex);
    //         default:
    //           return throw Error();
    //       }
    //     });
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
    // switch (value.toInt()) {
    //   case 0:
    //     text = const Text('M', style: style);
    //     break;
    //   case 1:
    //     text = const Text('T', style: style);
    //     break;
    //   case 2:
    //     text = const Text('W', style: style);
    //     break;
    //   case 3:
    //     text = const Text('T', style: style);
    //     break;
    //   case 4:
    //     text = const Text('F', style: style);
    //     break;
    //   case 5:
    //     text = const Text('S', style: style);
    //     break;
    //   case 6:
    //     text = const Text('S', style: style);
    //     break;
    //   default:
    //     text = const Text('', style: style);
    //     break;
    // }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: titleWidget,
    );
  }
}
