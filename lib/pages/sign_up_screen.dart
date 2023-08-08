import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:project/components/button_component.dart';
import 'package:project/model/auth/user.dart';
import 'package:project/controller/sign_up_controller.dart';
import 'package:project/pages/sign_in_screen.dart';
import 'package:project/pages/student_screen.dart';
import 'package:project/presentation/sizing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/input_field.dart';
import '../components/select_input_field.dart';
import '../components/spacing_component.dart';
import '../presentation/colors.dart';
import '../presentation/strings.dart';
import '../presentation/text_theme.dart';
import 'driver_page.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});
  static const String routeName = "/signUp";

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final controller = Get.put(SignUpController());
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: AppSizing.h_24, horizontal: AppSizing.h_24),
          child: SingleChildScrollView(
            child: SizedBox(
              height: AppSizing.deviceHeight(context),
              width: AppSizing.deviceWidth(context),
              child: Column(children: [
                Expanded(child: SvgPicture.asset(AppImageUrls.splashImage)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizing.h_24),
                  child: Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          const SpaceComponent(
                            factor: 40,
                            type: TYPE.vertical,
                          ),
                          Text(
                            "Lets Register you for BusTrack",
                            style: AppTextTheme.heading2(AppColors.primary,
                                fontSize: AppSizing.h_24),
                            textAlign: TextAlign.center,
                          ),
                          const SpaceComponent(
                            factor: 40,
                            type: TYPE.vertical,
                          ),
                          SelectTextField(
                            controller: controller.uerType,
                          ),
                          const SpaceComponent(
                            factor: 20,
                            type: TYPE.vertical,
                          ),
                          InputFieldComponent(
                            labelText: "your user name",
                            controller: controller.userName,
                          ),
                          const SpaceComponent(
                            factor: 20,
                            type: TYPE.vertical,
                          ),
                          InputFieldComponent(
                            labelText: "your email",
                            controller: controller.email,
                          ),
                          const SpaceComponent(
                            factor: 20,
                            type: TYPE.vertical,
                          ),
                          InputFieldComponent(
                            labelText: "your password",
                            obscureText: true,
                            controller: controller.password,
                          ),
                          const SpaceComponent(
                            factor: 20,
                            type: TYPE.vertical,
                          ),
                          InputFieldComponent(
                            labelText: "confirm password",
                            obscureText: _isPasswordObscured,
                            controller: controller.confirmPassword,
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
                          const SpaceComponent(
                            factor: 20,
                            type: TYPE.vertical,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizing.h_32),
                            child: ButtonComponent(
                              handler: () => handleSubmit(context),
                              label: "Register",
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account"),
                              TextButton(
                                  onPressed: () => handleLogin(context),
                                  child: const Text("sign in"))
                            ],
                          )
                        ],
                      )),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void handleSubmit(BuildContext context) async {
    UserModel user = UserModel(
      userName: controller.userName.text.trim(),
      email: controller.email.text.trim(),
      password: controller.password.text,
      userType: controller.uerType.dropDownValue!.value,
    );

    if (controller.validate(user, controller.confirmPassword.text)) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString("email", user.email);
      pref.setString("userType", user.userType);

      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: user.email, password: user.password)
          .then((value) {
        controller.registerUser(user);

        if (user.userType == "student") {
          Future.delayed(const Duration(seconds: 5), () {
            Navigator.of(context).pushReplacementNamed(StudentScreen.routeName,
                arguments: {"user": user});
          });
        } else if (user.userType == "driver") {
          Future.delayed(const Duration(seconds: 5), () {
            Navigator.of(context).pushReplacementNamed(DriverScreen.routeName,
                arguments: {"user": user});
          });
        }
      }).onError((error, stackTrace) {
        Get.snackbar("Error", error.toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.secondary,
            colorText: AppColors.light);
      });
    } else {
      Get.snackbar("Error", controller.errors[0],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.secondary,
          colorText: AppColors.light);
      controller.errors.clear();
      // controller.errors.clear();
    }

   
  }

  void handleLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
  }
}
