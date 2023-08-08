import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project/presentation/strings.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(AppImageUrls.splashImage);
  }
}
