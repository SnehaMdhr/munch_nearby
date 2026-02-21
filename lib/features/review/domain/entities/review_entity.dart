import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String? reviewId;
  final String customerId;
  final String? customerName;
  final String restaurantId;
  final int rating;
  final String comment;

  const ReviewEntity({
    this.reviewId,
    required this.customerId,
    this.customerName,
    required this.restaurantId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [
        reviewId,
        customerId,
        customerName,
        restaurantId,
        rating,
        comment,
      ];
}