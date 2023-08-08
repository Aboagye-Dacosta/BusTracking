import 'package:flutter/material.dart';

class AppPadding {
  static const double p_8 = 8.0;
  static const double p_16 = 16.0;
  static const double p_24 = 24.0;
  static const double p_100 = 100.0;
}

class AppSizing {
  static const double s_2 = 2.0;
  static const double s_4 = 4.0;
  static const double h_8 = 8.0;
  static const double h_16 = 16.0;
  static const double h_24 = 24.0;
  static const double h_32 = 32.0;
  static const double h_54 = 54.0;
  static const double h_80 = 80.0;
  static const double h_120 = 120.0;
  static const double h_250 = 250.0;

  static deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  static double spacingVertical(BuildContext context, double factor) =>
      AppSizing.deviceHeight(context) * 0.001 * factor;

  static double spacingHorizontal(BuildContext context, double factor) =>
      AppSizing.deviceWidth(context) * 0.001 * factor;
}

class AppFontSizes {
  static const double fs_8 = 8.0;
  static const double fs_16 = 16.0;
  static const double fs_24 = 24.0;
  static const double fs_48 = 48.0;
  static const double fs_32 = 32.0;
  static const double fs_120 = 120.0;
  
}
