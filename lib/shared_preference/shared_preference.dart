import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {

  static  get  instance async  => await SharedPreferences.getInstance();
}