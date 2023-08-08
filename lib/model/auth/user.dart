import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? userId;
  final String userName;
  final String password;
  final String email;
  final String userType;

  UserModel(
      {required this.userName,
      required this.password,
      required this.email,
      required this.userType,
      this.userId});

  toJson() {
    return {
      "userName": userName,
      "email": email,
      "password": password,
      "user_type": userType,
    };
  }

  factory UserModel.fromSnapShot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return UserModel(
      userId: doc.id,
      userName: data["userName"],
      email: data["email"],
      userType: data["user_type"],
      password: '',
    );
  }

  @override
  String toString() =>
      " { \nusername: ${userName}\nemail: ${email}\nuserType: ${userType} \n}";
}
