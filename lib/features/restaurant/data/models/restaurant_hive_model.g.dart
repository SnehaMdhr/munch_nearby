// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RestaurantHiveModelAdapter extends TypeAdapter<RestaurantHiveModel> {
  @override
  final int typeId = 1;

  @override
  RestaurantHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RestaurantHiveModel(
      id: fields[0] as String?,
      name: fields[1] as String,
      address: fields[2] as String,
      mapLink: fields[3] as String?,
      contactNumber: fields[4] as String,
      category: fields[5] as String?,
      description: fields[6] as String?,
      imageUrl: fields[7] as String?,
      owner: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RestaurantHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.mapLink)
      ..writeByte(4)
      ..write(obj.contactNumber)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.owner);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
