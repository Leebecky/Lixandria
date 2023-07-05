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
      applicationName: "Lixandria",
      applicationVersion: "4.0",
      applicationIcon: ImageIcon(
        AssetImage("assets/Lixandria-logo.png"),
        size: 50,
      ),
      children: <Widget>[
        Text(
          "Lixandria manages your personal collection of books! Take a photo of your books and easily record them down into your phone for easy reference when you're out and away from the house.",
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 15),
        Text(
            "This application was developed by Rebecca Lee, as a Final Year Project for Bsc (HONS) in Computer Science specialising in Intelligent System at Asia Pacific University."),
        SizedBox(height: 10),
        Text(
            "Books in Logo created by mavadee - Flaticon. Find it at: https://www.flaticon.com/free-icons/book")
      ],
    );
  }
}
