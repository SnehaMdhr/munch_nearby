// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReviewHiveModelAdapter extends TypeAdapter<ReviewHiveModel> {
  @override
  final int typeId = 4;

  @override
  ReviewHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReviewHiveModel(
      reviewId: fields[0] as String?,
      customerId: fields[1] as String,
      restaurantId: fields[2] as String,
      rating: fields[3] as int,
      comment: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.reviewId)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.restaurantId)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.comment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
