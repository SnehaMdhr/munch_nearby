import 'package:hive/hive.dart';

import 'package:munch_nearby/core/constants/hive_table_constant.dart';
import 'package:munch_nearby/features/customer_dashboard/domain/entities/upload_image_entity.dart';
import 'package:uuid/uuid.dart';

part 'upload_image_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class UploadImageHiveModel extends HiveObject {
  @HiveField(0)
  final String? media;

  @HiveField(1)
  final String? mediaType;

  UploadImageHiveModel({
    this.media,
    this.mediaType,
  });

  UploadImageEntity toEntity() {
    return UploadImageEntity(
      media: media,
      mediaType: mediaType,
    );
  }

  factory UploadImageHiveModel.fromEntity(UploadImageEntity entity) {
    return UploadImageHiveModel(
      media: entity.media,
      mediaType: entity.mediaType,
    );
  }

  static List<UploadImageEntity> toEntityList(List<UploadImageHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}

