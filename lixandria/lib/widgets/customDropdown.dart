import 'package:flutter/material.dart';

CustomDropdown(String? dropdownValue, List<String> dropdownItems,
    {String? labelTxt, onChangeFun}) {
  return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        value: dropdownValue,
        items: dropdownItems.map<DropdownMenuItem<String>>((String val) {
          return DropdownMenuItem<String>(value: val, child: Text(val));
        }).toList(),
        onChanged: onChangeFun,
        decoration: InputDecoration(
            border: const OutlineInputBorder(), labelText: labelTxt),
      ));
}
