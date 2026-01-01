import 'package:flutter/material.dart';
import 'package:munch_nearby/app/theme/theme_data.dart';
import 'package:munch_nearby/features/splash/presentation/pages/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: SplashScreen(),
    );
  }
}
