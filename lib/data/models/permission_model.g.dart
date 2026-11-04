// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PermissionModelAdapter extends TypeAdapter<PermissionModel> {
  @override
  final int typeId = 1;

  @override
  PermissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PermissionModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      fromDate: fields[3] as String,
      toDate: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PermissionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.fromDate)
      ..writeByte(4)
      ..write(obj.toDate)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
