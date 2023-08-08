import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

import '../presentation/sizing.dart';

class SelectTextField extends StatelessWidget {
  final String? Function(String? str)? validate;
  final SingleValueDropDownController? controller;

  final void Function(dynamic string)? onChange;

  const SelectTextField(
      {super.key, this.validate, this.onChange, this.controller});

  @override
  Widget build(BuildContext context) {
    return DropDownTextField(
      validator: validate,
      onChanged: onChange,
      controller: controller,
      dropdownRadius: AppSizing.h_8,
      textFieldDecoration: InputDecoration(
        labelText: "Choose user type",
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
            borderSide: const BorderSide(width: AppSizing.s_2),
            borderRadius: BorderRadius.circular(AppSizing.h_8)),
      ),
      dropDownList: const [
        DropDownValueModel(name: "student", value: "student"),
        DropDownValueModel(name: "driver", value: "driver"),
      ],
    );
  }
}
