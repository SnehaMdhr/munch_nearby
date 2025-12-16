import 'package:flutter/material.dart';
import 'package:munch_nearby/screens/login_screen.dart';
import 'package:munch_nearby/widgets/page_dot.dart';

import '../widgets/my_button.dart';


class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

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
                  );;
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
              Icons.message_sharp,
              size: 80,
              color: Color(0xFFE87A5D),
            ),

            const SizedBox(height: 40),

            // Title
            const Text(
              "Share your Taste, Shape\nYour future",
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
                "Your reviews power our recommendations. The more you share, the better we can tailor suggestions just for you and help the community",
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
                const PageDot(active: false),
                const PageDot(active: true),
              ],
            ),

            const SizedBox(height: 20),

            // Next button
            MyButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }, text: "Get Started"),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

