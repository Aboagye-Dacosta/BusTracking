import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/model/auth/user.dart';
import 'package:project/repository/user_repository.dart';
import 'package:project/presentation/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInController extends GetxController {
  static SignInController get instance => Get.find();

  final userRepo = Get.put(UserRepository());

  final password = TextEditingController();
  final uerType = SingleValueDropDownController();
  final email = TextEditingController();

  authenticate(UserModel user, void Function(bool isValid) callback) async {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: user.email, password: user.password)
        .then((value) async {
      final pref = await SharedPreferences.getInstance();
      final results = await userRepo.readUser(user.email);
      
      pref.setString("userId", results.userId!);
      callback(results.userType == user.userType);
    }).onError((error, stackTrace) {
      Get.snackbar(
          "Error", error.toString().replaceFirst("[firebase_auth/", "["),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.secondary,
          colorText: AppColors.light);
    });
  }

  controllerClear() {
    password.clear();
    email.clear();
    uerType.clearDropDown();
  }
}
