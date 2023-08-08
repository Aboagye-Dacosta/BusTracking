import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:project/pages/buss_detail_screen.dart";
import "package:project/pages/destinations_page.dart";
import "package:project/pages/driver_page.dart";
import "package:project/pages/sign_up_screen.dart";
import "package:project/pages/student_screen.dart";
import "package:provider/provider.dart";

import "../pages/splash_screen.dart";
import "../pages/sign_in_screen.dart";
import '../provider/location_provider.dart';

class App extends StatelessWidget {
  const App._internal();
  static const App _app = App._internal();

  factory App() {
    return _app;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => UserLocationProvider(),
        child: MyHomPage(),
      )
    ], child: MyHomPage());
  }
}

class MyHomPage extends StatelessWidget {
  const MyHomPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Busstrack",
      theme: ThemeData(fontFamily: "Poppins"),
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        SignInScreen.routeName: (context) => const SignInScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        StudentScreen.routeName: (context) => const StudentScreen(),
        BussDetail.routeName: (context) => const BussDetail(),
        DriverScreen.routeName: (context) => const DriverScreen(),
        DestinationPage.routName: (context) => const DestinationPage()
      },
    );
  }
}
