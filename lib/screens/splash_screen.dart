import 'package:av_master_mobile/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_splash/flutter_animated_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplash(
        type: Transition.fade,
        child:Text("Your Splash"),
        curve: Curves.fastEaseInToSlowEaseOut,
        backgroundColor: Colors.white,
        navigator:const Login(),
        durationInSeconds:3
    );
  }
}
