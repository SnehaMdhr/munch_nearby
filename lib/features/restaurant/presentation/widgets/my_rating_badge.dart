import 'package:flutter/material.dart';

class MyRatingBadge extends StatelessWidget {
  final int rating;
  final double starSize;
  final Color starColor;
  final Color borderColor;

  const MyRatingBadge({
    super.key,
    required this.rating,
    this.starSize = 18,
    this.starColor = const Color(0xFFE7744F),
    this.borderColor = const Color(0xFFFFD8C4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Prevents taking up full width in rows
        children: List.generate(
          5,
          (i) => Icon(
            i < rating ? Icons.star : Icons.star_border,
            size: starSize,
            color: starColor,
          ),
        ),
      ),
    );
  }
}
