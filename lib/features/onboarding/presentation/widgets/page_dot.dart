import 'package:flutter/material.dart';

class PageDot extends StatelessWidget {
  final bool active;
  const PageDot({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? Color(0xFFE87A5D): Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }
}
