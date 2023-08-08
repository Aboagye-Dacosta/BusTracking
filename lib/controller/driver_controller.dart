import 'package:get/get.dart';
import 'package:project/model/auth/user.dart';
import 'package:project/repository/user_repository.dart';

class DriverController extends GetxController {
  static DriverController get instance => Get.find();
  final userRepo = Get.put(UserRepository());

  Future<UserModel> loadDriverData(String email) async {
    final results = await userRepo.readUser(email);
    return results;
  }
}
