/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: customElevatedButton.dart
Description: Widget UI. Custom implementation of the ElevatedButton.
First Written On: 02/06/2023
Last Edited On:  12/06/2023
 */

import 'package:flutter/material.dart';

CustomElevatedButton(String btnText,
    {required Function onPressed,
    String btnSize = "small",
    double specificWidth = 0,
    Color textColour = Colors.white,
    Color btnColour = const Color(0xff285430)}) {
  double fontSize = (btnSize == "small")
      ? 20
      : (btnSize == "medium")
          ? 30
          : 40;

  double btnWidth = (specificWidth > 0)
      ? specificWidth
      : (btnSize == "large")
          ? 250
          : 150;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            elevation: 6.0,
            foregroundColor: textColour,
            backgroundColor: btnColour,
            minimumSize: (btnSize == "small")
                ? Size(btnWidth, 45)
                : (btnSize == "medium")
                    ? Size(btnWidth, 80)
                    : Size(btnWidth, 80),
            textStyle:
                TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
        onPressed: () {
          onPressed();
        },
        child: Text(btnText)),
  );
}
