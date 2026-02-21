import '../../domain/entities/review_entity.dart';

class ReviewApiModel {
  final String? reviewId;
  final String customerId;
  final String? customerName;
  final String restaurantId;
  final int rating;
  final String comment;

  ReviewApiModel({
    this.reviewId,
    required this.customerId,
    this.customerName,
    required this.restaurantId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      "customer": customerId,
      "restaurant": restaurantId,
      "rating": rating,
      "comment": comment,
    };
  }

  static String _extractId(dynamic value) {
    if (value is String) return value;

    if (value is Map<String, dynamic>) {
      final nestedId = value['_id'] ?? value['id'];
      if (nestedId is String) return nestedId;
    }

    return '';
  }

  static String? _extractCustomerName(dynamic customer) {
    if (customer is Map<String, dynamic>) {
      final dynamic name = customer['name'] ?? customer['username'] ?? customer['fullName'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    return null;
  }

  factory ReviewApiModel.fromJson(Map<String, dynamic> json) {
    return ReviewApiModel(
      reviewId: _extractId(json["_id"]).isNotEmpty
          ? _extractId(json["_id"])
          : _extractId(json["id"]),
      customerId: _extractId(json["customer"]).isNotEmpty
          ? _extractId(json["customer"])
          : _extractId(json["customerId"]),
      customerName: _extractCustomerName(json["customer"]),
      restaurantId: _extractId(json["restaurant"]).isNotEmpty
          ? _extractId(json["restaurant"])
          : _extractId(json["restaurantId"]),
      rating: (json["rating"] as num).toInt(),
      comment: json["comment"]?.toString() ?? "",
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      reviewId: reviewId,
      customerId: customerId,
      customerName: customerName,
      restaurantId: restaurantId,
      rating: rating,
      comment: comment,
    );
  }

  factory ReviewApiModel.fromEntity(ReviewEntity entity) {
    return ReviewApiModel(
      reviewId: entity.reviewId,
      customerId: entity.customerId,
      customerName: entity.customerName,
      restaurantId: entity.restaurantId,
      rating: entity.rating,
      comment: entity.comment,
    );
  }

  static List<ReviewEntity> toEntityList(List<ReviewApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}