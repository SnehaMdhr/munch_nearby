import '../../domain/entities/review_entity.dart';

class ReviewApiModel {
  final String? reviewId;
  final String customerId;
  final String? customerName;
  final String? customerImageUrl;
  final DateTime? createdAt;
  final String restaurantId;
  final int rating;
  final String comment;

  ReviewApiModel({
    this.reviewId,
    required this.customerId,
    this.customerName,
    this.customerImageUrl,
    this.createdAt,
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
      final dynamic name =
          customer['name'] ?? customer['username'] ?? customer['fullName'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    return null;
  }

  static String? _extractCustomerImageUrl(dynamic customer) {
    if (customer is Map<String, dynamic>) {
      final dynamic image =
          customer['imageUrl'] ??
          customer['imageurl'] ??
          customer['image'] ??
          customer['avatar'] ??
          customer['profilePicture'];
      if (image != null && image.toString().trim().isNotEmpty) {
        return image.toString();
      }
    }

    return null;
  }

  static DateTime? _extractDateTime(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim())?.toLocal();
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }

    return null;
  }

  factory ReviewApiModel.fromJson(Map<String, dynamic> json) {
    final customerPayload = json["customer"] ?? json["user"];

    return ReviewApiModel(
      reviewId: _extractId(json["_id"]).isNotEmpty
          ? _extractId(json["_id"])
          : _extractId(json["id"]),
      customerId: _extractId(customerPayload).isNotEmpty
          ? _extractId(customerPayload)
          : _extractId(json["customerId"]),
      customerName: _extractCustomerName(customerPayload),
      customerImageUrl: _extractCustomerImageUrl(customerPayload),
      createdAt: _extractDateTime(
        json["createdAt"] ?? json["created_at"] ?? json["date"],
      ),
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
      customerImageUrl: customerImageUrl,
      createdAt: createdAt,
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
      customerImageUrl: entity.customerImageUrl,
      createdAt: entity.createdAt,
      restaurantId: entity.restaurantId,
      rating: entity.rating,
      comment: entity.comment,
    );
  }

  static List<ReviewEntity> toEntityList(List<ReviewApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
