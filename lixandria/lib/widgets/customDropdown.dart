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
