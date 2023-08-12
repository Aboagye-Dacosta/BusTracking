import 'package:flutter/material.dart';

import '../presentation/colors.dart';
import '../presentation/sizing.dart';

class RadioTile extends StatelessWidget {
  final String value;
  final String label;
  final String? groupValue;
  final void Function()? onTap;
  final void Function(String?)? onChanged;
  final bool? disabled;
  const RadioTile({
    super.key,
    this.groupValue,
    this.onTap,
    this.onChanged,
    required this.value,
    required this.label,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        child: Container(
          // width: AppSizing.h_120,
          height: AppFontSizes.fs_48,
          padding: disabled == false
              ? const EdgeInsets.symmetric(horizontal: AppSizing.h_8)
              : const EdgeInsets.symmetric(
                  horizontal: AppSizing.h_16, vertical: 10),
          margin: const EdgeInsets.all(AppSizing.s_2),

          decoration: BoxDecoration(
              color: groupValue == value && disabled == false
                  ? AppColors.primary
                  : disabled == true
                      ? AppColors.gray
                      : AppColors.light,
              border: Border.all(
                  width: 1.0,
                  color: groupValue == value ? AppColors.primary : Colors.grey),
              borderRadius: BorderRadius.circular(AppSizing.h_54)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (disabled == false)
                Radio(
                  value: value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  toggleable: true, 
                ),
              Text(
                label,
                style: TextStyle(
                    color:
                        groupValue == value ? AppColors.light : AppColors.dark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
