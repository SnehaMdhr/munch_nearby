import 'package:flutter/material.dart';
import 'package:munch_nearby/screens/login_screen.dart';
import 'package:munch_nearby/screens/onboarding_screen1.dart';
import '../widgets/my_button.dart';
import '../widgets/page_dot.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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
              Icons.restaurant_menu,
              size: 80,
              color: Color(0xFFE87A5D),
            ),

            const SizedBox(height: 40),

            // Title
            const Text(
              "Discover delicious\nfood nearby.",
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
                "MunchNearby helps you easily find the best local restaurants, "
                    "from hidden gems to popular favorites.",
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
                const PageDot(active: true),
                const PageDot(active: false),
                const PageDot(active: false),
              ],
            ),

            const SizedBox(height: 20),

            // Next button
            MyButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OnboardingScreen1()),
              );
            }, text: "Next"),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
