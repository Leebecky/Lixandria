import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

CustomTextField(TextEditingController ctrl, String? labelMsg,
    {String? helpMsg,
    String? errorMsg,
    bool isRequired = true,
    bool isNumericOnly = false,
    customValidator}) {
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: (isNumericOnly) ? TextInputType.number : null,
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
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: labelMsg,
            helperText: helpMsg),
      ));
}
