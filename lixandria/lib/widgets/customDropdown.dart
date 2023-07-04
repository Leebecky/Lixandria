/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: customDropdown.dart
Description: Widget UI. Custom implementation of the Dropdown.
First Written On: 02/06/2023
Last Edited On:  12/06/2023
 */

import 'package:flutter/material.dart';

CustomDropdown(String? dropdownValue,
    {List<String>? dropdownText,
    List<DropdownMenuItem<String>>? dropdownItems,
    String? labelTxt,
    onChangeFun,
    validateFun,
    onTap}) {
  return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        value: dropdownValue,
        items: (dropdownItems == null)
            ? dropdownText!.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(value: val, child: Text(val));
              }).toList()
            : dropdownItems,
        onChanged: onChangeFun,
        onTap: onTap,
        validator: validateFun,
        decoration: InputDecoration(
            border: const OutlineInputBorder(), labelText: labelTxt),
      ));
}
