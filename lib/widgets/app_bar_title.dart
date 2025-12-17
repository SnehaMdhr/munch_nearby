import 'package:flutter/material.dart';

class AppBarTitle extends StatelessWidget {
  final String name;

  const AppBarTitle({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 12,),
        Container(
          height: 60,
          child: Image.asset(
            'assets/images/nobg_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: 12,),
        Text(
          "Hello, $name!",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: "PlusJakarta Bold",
          ),
        ),
      ],
    );
  }
}
