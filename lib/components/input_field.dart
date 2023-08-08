import 'package:flutter/material.dart';

import '../presentation/sizing.dart';

class InputFieldComponent extends StatefulWidget {
  final String? Function(String? str)? validate;
  final void Function(String str)? onChanged;
  final Widget? leadingIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? labelText;
  final bool obscureText;

  const InputFieldComponent({
    this.validate,
    this.labelText = "label",
    this.obscureText = false,
    this.onChanged,
    super.key,
    this.controller,
    this.leadingIcon,
    this.suffixIcon,
  });

  @override
  State<InputFieldComponent> createState() => _InputFieldComponentState();
}

class _InputFieldComponentState extends State<InputFieldComponent> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      validator: widget.validate,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        icon: widget.leadingIcon,
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: AppSizing.s_2,
            ),
            borderRadius: BorderRadius.circular(AppSizing.h_8)),
      ),
    );
  }
}
