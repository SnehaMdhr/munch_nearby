// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_image_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UploadImageHiveModelAdapter extends TypeAdapter<UploadImageHiveModel> {
  @override
  final int typeId = 0;

  @override
  UploadImageHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UploadImageHiveModel(
      media: fields[0] as String?,
      mediaType: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UploadImageHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.media)
      ..writeByte(1)
      ..write(obj.mediaType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadImageHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
