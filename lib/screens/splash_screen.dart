import 'dart:async';
import 'package:toy_exchange_app/constants/validators.dart';
import 'package:toy_exchange_app/constants/widgets.dart';
import 'package:toy_exchange_app/screens/admin/admin_home_screen.dart';
import 'package:toy_exchange_app/screens/main_navigatiion_screen.dart';
import 'package:toy_exchange_app/constants/colors.dart';
import 'package:toy_exchange_app/screens/welcome_screen.dart';
import 'package:toy_exchange_app/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  static const String screenId = 'splash_screen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Auth authService = Auth();
  @override
  void initState() {
    permissionBasedNavigationFunc();
    super.initState();
  }

  permissionBasedNavigationFunc() {
    Timer(const Duration(seconds: 4), () async {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user == null) {
          Navigator.pushNamedAndRemoveUntil(context, WelcomeScreen.screenId,(route)=> false);
        } else if(user.email == kAdminEmail) {
          Navigator.pushNamedAndRemoveUntil(
              context, AdminHomeScreen.screenId,(route)=> false);
        }else{
          if(await authService.getBlocked()){
            customSnackBar(context: context, content: "Your are blocked by admin\ndue to voilation of our term and services.");
            Navigator.pushNamedAndRemoveUntil(context, WelcomeScreen.screenId,(route)=> false);
          }else{
            Navigator.pushNamedAndRemoveUntil(
                context, MainNavigationScreen.screenId,(route)=> false);
          }

        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(top: 250),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Toys Exchange',
                  style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
                Text(
                  'Exchange your Toys here !',
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            height: MediaQuery.of(context).size.height,
            child: Lottie.asset(
              "assets/lottie/splash_lottie.json",
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      ),
    );
  }
}
