/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: customTextfield.dart
Description: Widget UI. Custom implementation of the Textfield.
First Written On: 02/06/2023
Last Edited On:  12/06/2023
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

CustomTextField(TextEditingController ctrl, String? labelMsg,
    {String? helpMsg,
    String? errorMsg,
    bool isRequired = true,
    bool isNumericOnly = false,
    bool isMultiline = false,
    int lineCount = 1,
    customValidator}) {
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: (isNumericOnly)
            ? TextInputType.number
            : (isMultiline)
                ? TextInputType.multiline
                : null,
        inputFormatters:
            (isNumericOnly) ? [FilteringTextInputFormatter.digitsOnly] : [],
        validator: (customValidator == null)
            ? (value) {
                if (isRequired) {
                  if (value == null || value.isEmpty) {
                    return errorMsg;
                  }
                }
                return null;
              }
            : customValidator,
        maxLines: (isMultiline)
            ? null
            : (lineCount > 1)
                ? lineCount
                : 1,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: labelMsg,
            helperText: helpMsg),
      ));
}
