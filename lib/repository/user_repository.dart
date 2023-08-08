import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:project/presentation/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/auth/user.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final collection = "Users";

  createUser(UserModel user) async {
    final pref = await SharedPreferences.getInstance();
    await _db.collection(collection).add(user.toJson()).then((value) {
      pref.setString("userId", value.id);
      Get.snackbar(
        "Success",
        "Your account has been created",
        backgroundColor: AppColors.active,
        colorText: AppColors.light,
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
      );
      // ignore: body_might_complete_normally_catch_error
    }).catchError((error, stackTrace) {
      Get.snackbar(
        "Error",
        "Your account has been created",
        backgroundColor: AppColors.active,
        colorText: AppColors.light,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  Future<UserModel> readUser(String email) async {
    final snapshot =
        await _db.collection(collection).where("email", isEqualTo: email).get();

    final userData = snapshot.docs.map((e) => UserModel.fromSnapShot(e)).single;
    return userData;
  }
}
