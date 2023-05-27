import 'package:flutter/material.dart';

CustomElevatedButton(context, formKey, String btnText,
    {required Function onPressed,
    Color textColour = Colors.white,
    Color btnColour = const Color(0xff285430)}) {
  return Padding(
    padding: const EdgeInsets.only(top: 12.0),
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            foregroundColor: textColour,
            backgroundColor: btnColour,
            minimumSize: const Size(150, 45),
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        onPressed: () {
          onPressed();
        },
        child: Text(btnText)),
  );
}
