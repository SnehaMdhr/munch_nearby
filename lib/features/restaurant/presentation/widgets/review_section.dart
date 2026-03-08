import 'package:flutter/material.dart';
import 'package:munch_nearby/features/review/presentation/state/review_state.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/review_card.dart';

class ReviewSection extends StatelessWidget {
  final ReviewState state;
  final String? currentUserId;
  final Function(ReviewEntity) onEdit;
  final Function(String) onDelete;
  final String? Function(String) normalizeImageUrl;
  final String Function(DateTime?, {String? reviewId}) formatDate;

  const ReviewSection({
    super.key,
    required this.state,
    this.currentUserId,
    required this.onEdit,
    required this.onDelete,
    required this.normalizeImageUrl,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Loading State
    if (state.status == ReviewStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. Empty State
    if (state.reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            "No reviews yet.",
            style: TextStyle(
              color: Color(0xFF8E97A8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // 3. List of Review Cards
    return Column(
      children: state.reviews.map((review) {
        return ReviewCard(
          review: review,
          currentUserId: currentUserId,
          onEdit: onEdit,
          onDelete: onDelete,
          normalizeImageUrl: normalizeImageUrl,
          formatDate: formatDate,
        );
      }).toList(),
    );
  }
}
