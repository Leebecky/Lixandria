/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: customAlertDialog.dart
Description: Widget UI. Custom implementation of the alert dialog.
First Written On: 02/06/2023
Last Edited On:  12/06/2023
 */

import 'package:flutter/material.dart';

CustomAlertDialog(BuildContext context, String hdrMsg, String bodyMsg,
    {confirmOnPressed}) {
  return AlertDialog(
    title: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Text(
        hdrMsg,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    titlePadding: const EdgeInsets.all(0),
    actionsPadding: const EdgeInsets.all(10),
    content: Text(bodyMsg),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: confirmOnPressed,
        child: const Text(
          'Confirm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}
