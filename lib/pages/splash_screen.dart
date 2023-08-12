
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:project/components/spacing_component.dart';
import 'package:project/pages/driver_page.dart';
import 'package:project/pages/sign_in_screen.dart';
import 'package:project/pages/student_screen.dart';
import 'package:project/presentation/colors.dart';
import 'package:project/presentation/sizing.dart';
import 'package:project/presentation/strings.dart';
import 'package:project/presentation/text_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final int delays = 5;

  @override
  void initState() {
    Future.delayed(Duration(seconds: delays), () async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      try {
        String? email = pref.getString("email");
        String? userType = pref.getString("userType");

        if (email == null && userType == null) {
         Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
        } else {
          if (userType == "student") {
           Navigator.of(context).pushReplacementNamed(StudentScreen.routeName);
          } else {
           Navigator.of(context).pushReplacementNamed(DriverScreen.routeName);
          }
        }
      } catch (e) {
     
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void handleNext() => {};

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: AppSizing.deviceHeight(context),
          width: AppSizing.deviceWidth(context),
          padding: const EdgeInsets.symmetric(
              vertical: AppPadding.p_24, horizontal: AppPadding.p_8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2, child: SvgPicture.asset(AppImageUrls.splashImage)),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          AppStrings.splashScreenMainText,
                          style:
                              AppTextTheme.heading1(color: AppColors.primary),
                        ),
                        const SpaceComponent(
                          factor: 2,
                          type: TYPE.vertical,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p_24),
                          child: Text(
                            AppStrings.splashScreenSubText,
                            style:
                                AppTextTheme.subTitle1(color: AppColors.gray),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: TextButton(
                  //     onPressed: handleNext,
                  //     child: Text(
                  //       AppButtonStrings.splashScreenButtonString,
                  //       style: AppTextTheme.textNormalMd(
                  //         color: AppColors.primaryLight,
                  //         fontSize: AppFontSizes.fs_16,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
