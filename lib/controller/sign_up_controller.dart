import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/repository/user_repository.dart';

import '../model/auth/user.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();
  List<String> errors = [];

  final userName = TextEditingController();
  final password = TextEditingController();
  final uerType = SingleValueDropDownController();
  final confirmPassword = TextEditingController();
  final email = TextEditingController();

  final userRepo = Get.put(UserRepository());

  registerUser(
    UserModel user,
  ) {
    userRepo.createUser(user);
  }

  validate(UserModel user, String confirmPassword) {
    validateUserType(user.userType);
    validateUserName(user.userName);
    validEmail(user.email);
    validatePassword(user.password, confirmPassword);

    if (errors.isEmpty) {
      return true;
    }

    return false;
  }

  validEmail(String email) {
    if (email.isEmpty) {
      errors.add("Your email is required");
    }

    if (!_isValidEmail(email)) {
      errors.add("Email format is invalid");
    }
  }

  bool _isValidEmail(String email) {
    // Define a regex pattern for email validation
    final RegExp emailRegExp = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.[a-zA-Z]{2,})$',
    );

    return emailRegExp.hasMatch(email);
  }

  validateUserName(String username) {
    if (!_isValidUsername(username)) {
      errors.add("Your user name is must have a minimum length of 3");
    }
  }

  validateUserType(String userType) {
    if (userType.isEmpty) {
      errors.add("User type is required");
    }
  }

  bool _isValidUsername(String username) {
    // Define a regex pattern for username validation
    final RegExp usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,}$');

    return usernameRegExp.hasMatch(username);
  }

  validatePassword(String password, String confirmPassword) {
    if (password.length < 8) {
      errors.add("Password length must be at least 8");
    }

    if (password != confirmPassword) {
      errors.add("password do not match");
    }
  }
}
