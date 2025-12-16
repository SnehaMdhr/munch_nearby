import 'package:flutter/material.dart';
import 'package:munch_nearby/screens/login_screen.dart';
import 'package:munch_nearby/screens/onboarding_screen2.dart';
import '../widgets/my_button.dart';
import '../widgets/page_dot.dart';


class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Color(0xFFE87A5D),
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 150),

            // Icon
            const Icon(
              Icons.restaurant,
              size: 80,
              color: Color(0xFFE87A5D),
            ),

            const SizedBox(height: 40),

            // Title
            const Text(
              "All The Details You Need",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text(
                "Access full menus, check honest ratings, and find all the info you need before you even leave the house.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ),

            const Spacer(),

            // Page indicator (static example)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PageDot(active: false),
                const PageDot(active: true),
                const PageDot(active: false),
              ],
            ),

            const SizedBox(height: 20),

            // Next button
            MyButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OnboardingScreen2()),
              );
            }, text: "Next"),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


