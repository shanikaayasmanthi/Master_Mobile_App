import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        // You can put your app logo or a simple text here.
        // The CircularProgressIndicator gives a visual cue that something is loading.
        child: CircularProgressIndicator(),
      ),
    );
  }
}