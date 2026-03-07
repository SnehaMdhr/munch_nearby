import 'package:flutter/material.dart';

class ReviewActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double iconSize;

  const ReviewActionButtons({
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Edit Review',
          icon: Icon(Icons.edit_outlined, size: iconSize, color: Colors.blue),
          onPressed: onEdit,
        ),
        IconButton(
          tooltip: 'Delete Review',
          icon: Icon(Icons.delete_outline, size: iconSize, color: Colors.red),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
