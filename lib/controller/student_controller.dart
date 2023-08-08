import 'package:get/get.dart';
import 'package:project/repository/user_repository.dart';

class StudentController extends GetxController {
  static StudentController get instance => Get.find();

  final studentRepo = Get.put(UserRepository());

  loadStudentData(String email) async {
    return await studentRepo.readUser(email);
  }
}
