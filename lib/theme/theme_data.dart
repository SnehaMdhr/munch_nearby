import 'package:flutter/material.dart';

ThemeData getApplicationTheme(){
  return ThemeData(
    fontFamily: "PlusJakarta Regular",
    useMaterial3: true,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,

      titleSpacing: 0,
    ),
  );
}