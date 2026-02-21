import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:munch_nearby/core/services/storage/user_session_service.dart';
import 'package:munch_nearby/features/review/domain/entities/review_entity.dart';
import 'package:munch_nearby/features/review/presentation/view_model/review_view_model.dart';
import '../state/review_state.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const ReviewScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(reviewViewModelProvider.notifier)
        .loadRestaurantReviews(widget.restaurantId));
  }

  // --- 1. SHOW ADD/EDIT SHEET ---
  void _openReviewSheet({ReviewEntity? existingReview}) {
    final isEditing = existingReview != null;
    final commentController =
        TextEditingController(text: isEditing ? existingReview.comment : "");
    int selectedRating = isEditing ? existingReview.rating : 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? "Edit Your Review" : "Write a Review",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () =>
                          setModalState(() => selectedRating = index + 1),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Share your experience...",
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: isEditing ? Colors.blue : Colors.deepOrange),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEditing ? Colors.blue : Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (commentController.text.trim().length < 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Min 5 characters required")),
                      );
                      return;
                    }

                    final reviewData = ReviewEntity(
                      customerId: existingReview?.customerId ?? '',
                      restaurantId: widget.restaurantId,
                      rating: selectedRating,
                      comment: commentController.text.trim(),
                    );

                    if (isEditing) {
                      ref
                          .read(reviewViewModelProvider.notifier)
                          .updateReview(existingReview.reviewId!, reviewData);
                    } else {
                      ref
                          .read(reviewViewModelProvider.notifier)
                          .addReview(reviewData);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    isEditing ? "Update Review" : "Submit Review",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. DELETE CONFIRMATION ---
  void _confirmDelete(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Review?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref
                  .read(reviewViewModelProvider.notifier)
                  .deleteReview(reviewId, widget.restaurantId);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewViewModelProvider);
    final currentUserId = ref.watch(userSessionServiceProvider).getCurrentUserId();

    return Scaffold(
      appBar: AppBar(title: Text(widget.restaurantName), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openReviewSheet(),
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: const Text("Write Review", style: TextStyle(color: Colors.white)),
      ),
      body: _buildBody(state, currentUserId),
    );
  }

  Widget _buildBody(ReviewState state, String? currentUserId) {
    if (state.status == ReviewStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.reviews.isEmpty) {
      return const Center(child: Text("No reviews yet. Be the first!"));
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      itemCount: state.reviews.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final review = state.reviews[index];
        final bool isMyReview = review.customerId == currentUserId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isMyReview ? Colors.blue.shade100 : Colors.deepOrange.shade100,
                  child: Text(
                    review.customerName?[0].toUpperCase() ?? "?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMyReview ? Colors.blue : Colors.deepOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMyReview ? "You" : (review.customerName ?? "Anonymous"),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 14, color: Colors.amber,
                        )),
                      ),
                    ],
                  ),
                ),
                if (isMyReview) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: () => _openReviewSheet(existingReview: review),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(review.reviewId!),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: Text(review.comment, style: const TextStyle(fontSize: 14, height: 1.4)),
            ),
          ],
        );
      },
    );
  }
}