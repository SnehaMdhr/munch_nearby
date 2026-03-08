import 'package:flutter/material.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/my_rating_badge.dart';
import 'package:munch_nearby/features/restaurant/presentation/widgets/review_action_button.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';

class ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  final String? currentUserId;
  final Function(ReviewEntity) onEdit;
  final Function(String) onDelete;
  final String? Function(String) normalizeImageUrl;
  final String Function(DateTime?, {String? reviewId}) formatDate;

  const ReviewCard({
    super.key,
    required this.review,
    this.currentUserId,
    required this.onEdit,
    required this.onDelete,
    required this.normalizeImageUrl,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMyReview = review.customerId == currentUserId;
    final reviewerName = review.customerName?.trim().isNotEmpty == true
        ? review.customerName!
        : 'Guest';
    final reviewerImageUrl = normalizeImageUrl(review.customerImageUrl ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFFDEEE9),
                backgroundImage: reviewerImageUrl == null
                    ? null
                    : NetworkImage(reviewerImageUrl),
                child: reviewerImageUrl == null
                    ? Text(
                        reviewerName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE7744F),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  isMyReview ? 'You' : reviewerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2A44),
                  ),
                ),
              ),
              MyRatingBadge(rating: review.rating),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '"${review.comment}"',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: Color(0xFF4C586E),
            ),
          ),
          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDate(review.createdAt, reviewId: review.reviewId),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E97A8),
                ),
              ),
              if (isMyReview)
                ReviewActionButtons(
                  onEdit: () => onEdit(review),
                  onDelete: () => onDelete(review.reviewId!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
