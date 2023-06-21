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
