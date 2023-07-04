/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: credits.dart
Description: UI Page. Handles the presentation of app credits/licenses and relevant business logic.
First Written On: 19/06/2023
Last Edited On:  23/06/2023
 */

import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AboutDialog(
      children: <Widget>[
        Text("Lixandria App Description"),
        Text(
            "Books in Logo created by mavadee - Flaticon. Find it at: https://www.flaticon.com/free-icons/book")
      ],
    );
  }
}
