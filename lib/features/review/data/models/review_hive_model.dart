import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/hive_table_constant.dart';
import '../../domain/entities/review_entity.dart';

part 'review_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.reviewTypeId)
class ReviewHiveModel extends HiveObject {
  @HiveField(0)
  final String reviewId;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String restaurantId;

  @HiveField(3)
  final int rating;

  @HiveField(4)
  final String comment;

  ReviewHiveModel({
    String? reviewId,
    required this.customerId,
    required this.restaurantId,
    required this.rating,
    required this.comment,
  }) : reviewId = reviewId ?? const Uuid().v4();

  // Convert from Entity to Hive Model
  factory ReviewHiveModel.fromEntity(ReviewEntity entity) {
    return ReviewHiveModel(
      reviewId: entity.reviewId,
      customerId: entity.customerId,
      restaurantId: entity.restaurantId,
      rating: entity.rating,
      comment: entity.comment,
    );
  }

  // Convert from Hive Model to Entity
  ReviewEntity toEntity() {
    return ReviewEntity(
      reviewId: reviewId,
      customerId: customerId,
      restaurantId: restaurantId,
      rating: rating,
      comment: comment,
    );
  }

  // Helper to convert a list of Hive models to Entities
  static List<ReviewEntity> toEntityList(List<ReviewHiveModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}