import 'package:flutter/material.dart';
import 'package:munch_nearby/features/auth/presentation/pages/login_screen.dart';
import 'package:munch_nearby/features/onboarding/presentation/widgets/build_page.dart';
import '../../../auth/presentation/widgets/my_button.dart';
import '../widgets/page_dot.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      BuildPage(
        icon: Icons.restaurant_menu,
        title: "Discover delicious\nfood nearby.",
        subtitle:
            "MunchNearby helps you easily find the best local restaurants, from hidden gems to popular favorites.",
      ),
      BuildPage(
        icon: Icons.map_outlined,
        title: "Explore nearby restaurants",
        subtitle: "Find local restaurants near you in just a few taps.",
      ),
      BuildPage(
        icon: Icons.star_border,
        title: "Rate & favorite",
        subtitle:
            "Save your favorite places and rate your dining experience easily.",
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipToLogin,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Color(0xFFE87A5D),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return pages[index];
                },
              ),
            ),

            // Page Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => PageDot(active: _currentPage == index),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: MyButton(
                  onPressed: _nextPage,
                  text: _currentPage == pages.length - 1
                      ? "Get Started"
                      : "Next",
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
