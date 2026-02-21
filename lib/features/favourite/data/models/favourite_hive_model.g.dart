// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavouriteHiveModelAdapter extends TypeAdapter<FavouriteHiveModel> {
  @override
  final int typeId = 3;

  @override
  FavouriteHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavouriteHiveModel(
      favouriteId: fields[0] as String?,
      customerId: fields[1] as String,
      restaurantId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavouriteHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.favouriteId)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.restaurantId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouriteHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
