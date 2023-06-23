import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:lixandria/pages/statistics/statistics_tag_distribution.dart';
import 'package:lixandria/pages/statistics/statistics_book_by_ownership.dart';
import 'package:lixandria/pages/statistics/statistics_book_by_shelves.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  int touchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BooksByShelves(),
            BooksByOwnership(),
            TagWordcloud(),
          ]),
    );
  }
}
