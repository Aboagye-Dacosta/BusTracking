import 'package:flutter/material.dart';

import '../presentation/colors.dart';
import '../presentation/sizing.dart';

class ButtonComponent extends StatelessWidget {
  final String label;
  final VoidCallback? handler;
  const ButtonComponent({super.key, this.label = "label", this.handler});

  get handleSubmit => null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizing.h_54,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: handler,
          child: Text(label)),
    );
  }
}
