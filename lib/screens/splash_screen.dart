import 'package:flutter/material.dart';



class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.pushReplacementNamed(context, "/onboarding");
      });
    });
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          "assets/images/logo.png",
          fit: BoxFit.cover,
        ),),
    );
  }
}
