/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: statistics.dart
Description: UI Page. Displays the statistics page and handles relevant business logic.
First Written On: 18/06/2023
Last Edited On:  23/06/2023
 */

import 'package:flutter/material.dart';
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
