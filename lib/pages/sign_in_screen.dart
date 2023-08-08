import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:project/components/button_component.dart';
import 'package:project/components/select_input_field.dart';
import 'package:project/model/auth/user.dart';
import 'package:project/pages/driver_page.dart';
import 'package:project/pages/sign_up_screen.dart';
import 'package:project/pages/student_screen.dart';
import 'package:project/presentation/colors.dart';
import 'package:project/presentation/sizing.dart';
import 'package:project/presentation/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/input_field.dart';
import '../components/spacing_component.dart';
import '../controller/sign_in_controller.dart';
import '../presentation/text_theme.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  static const String routeName = "/signIn";

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final controller = Get.put(SignInController());
  bool _isPasswordObscured = true;

  void handleRegister() {
    Navigator.of(context).pushReplacementNamed(SignUpScreen.routeName);
  }

  void handleSubmit(BuildContext context) {
    final user = UserModel(
      email: controller.email.text.trim(),
      password: controller.password.text,
      userType: controller.uerType.dropDownValue!.value,
      userName: '',
    );

    controller.authenticate(user, (isValid) async {
      if (isValid) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("email", user.email);
        prefs.setString("userType", user.userType);

        if (user.userType == "student") {
          Navigator.of(context).pushReplacementNamed(StudentScreen.routeName);
          controller.controllerClear();
        } else if (user.userType == "driver") {
          Navigator.of(context).pushReplacementNamed(DriverScreen.routeName);
          controller.controllerClear();
        }
      } else {
        Get.snackbar("Error", "Sorry check your details and try again",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.secondary,
            colorText: AppColors.light);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: AppSizing.deviceHeight(context),
            width: AppSizing.deviceWidth(context),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizing.h_80),
                  child: SvgPicture.asset(
                    AppImageUrls.splashImage,
                  ),
                ),
              ),
              Text(
                "Welcome to BusTrack",
                style: AppTextTheme.heading2(AppColors.primary,
                    fontSize: AppSizing.h_24),
              ),
              const SpaceComponent(
                factor: 20,
                type: TYPE.vertical,
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizing.h_54),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SelectTextField(
                        controller: controller.uerType,
                      ),
                      const SpaceComponent(
                        factor: 16,
                        type: TYPE.vertical,
                      ),
                      InputFieldComponent(
                        labelText: "email",
                        controller: controller.email,
                      ),
                      const SizedBox(
                        height: AppSizing.h_16,
                      ),
                      InputFieldComponent(
                        labelText: "password",
                        controller: controller.password,
                        obscureText: _isPasswordObscured,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
                          child: _isPasswordObscured
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                      ),
                      const SizedBox(
                        height: AppSizing.h_16,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizing.h_32),
                        child: ButtonComponent(
                          handler: () => handleSubmit(context),
                          label: "continue",
                        ),
                      ),
                      const SpaceComponent(
                        factor: 2,
                        type: TYPE.vertical,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account"),
                          TextButton(
                              onPressed: handleRegister,
                              child: const Text("register"))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
