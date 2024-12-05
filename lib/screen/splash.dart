import 'package:aspire/helper/app_common.dart';
import 'package:aspire/screen/auth/login.dart';
import 'package:aspire/screen/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await Future.delayed(const Duration(seconds: 2));
    Get.offAll(SignInScreen());
    // Get.offAll(DashBoardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:  ClipRRect(
                    borderRadius: radius(50),
                    child: Image.asset("assets/logo.jpeg", width: 100, height: 100),
                  ),
        // child: Image.asset("assets/logo.jpeg",
        //     fit: BoxFit.contain, height: 150, width: 150),
      ),
    );
  }
}
