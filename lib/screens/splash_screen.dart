import 'package:flutter/material.dart';
import 'package:munch_nearby/screens/onboarding_screen.dart';



class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
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
