import 'package:flutter/material.dart';
import 'package:project/presentation/sizing.dart';

TextStyle defaultTextStyle(
        {double fontSize = AppFontSizes.fs_16,
        Color color = Colors.indigo,
        FontWeight fontWeight = FontWeight.normal}) =>
    TextStyle(fontWeight: fontWeight, fontSize: fontSize, color: color);

class AppTextTheme {
  static TextStyle heading1({Color color = Colors.black}) => TextStyle(
        fontSize: AppFontSizes.fs_48,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle heading2(Color color, {double? fontSize = AppSizing.h_32}) =>
      defaultTextStyle(
        fontSize: fontSize!,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle subTitle1(
          {double fontSize = AppFontSizes.fs_16, Color color = Colors.grey}) =>
      defaultTextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        color: color,
      );
  static TextStyle textNormalSm(
          {double fontSize = AppSizing.h_8, Color color = Colors.black}) =>
      defaultTextStyle(fontSize: fontSize, color: color);
  static TextStyle textNormalMd(
          {double fontSize = AppSizing.h_16, Color color = Colors.black}) =>
      defaultTextStyle(fontSize: fontSize, color: color);
}
