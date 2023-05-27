import 'package:flutter/material.dart';

CustomTextField(
    TextEditingController ctrl, String? labelMsg, String? errorMsg) {
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: TextFormField(
        controller: ctrl,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMsg;
          }
        },
        decoration: InputDecoration(
            border: const OutlineInputBorder(), labelText: labelMsg),
      ));
}
