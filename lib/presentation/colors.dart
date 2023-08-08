import 'package:flutter/material.dart';

class AppColors {
  static Color primaryDark = HexColor.fromHex("03045e");
  static Color primary = HexColor.fromHex("023e8a");
  static Color primaryLight = HexColor.fromHex("0077b6");
  static Color secondary = HexColor.fromHex("ef233c");
  static Color dark = HexColor.fromHex("1b263b");
  static Color light = HexColor.fromHex("f8f9fa");
  static Color gray = HexColor.fromHex("adb5bd");
  static Color active = HexColor.fromHex("06E20E");
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write("ff");
    buffer.write(hexString.replaceFirst("#", ""));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
