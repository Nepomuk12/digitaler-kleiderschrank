// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing_item_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClothingItemAdapter extends TypeAdapter<ClothingItem> {
  @override
  final int typeId = 2;

  @override
  ClothingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClothingItem(
      id: fields[0] as String,
      category: fields[1] as ClothingCategory,
      imagePath: fields[2] as String,
      createdAt: fields[3] as int,
      tags: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ClothingItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothingItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClothingCategoryAdapter extends TypeAdapter<ClothingCategory> {
  @override
  final int typeId = 1;

  @override
  ClothingCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClothingCategory.top;
      case 1:
        return ClothingCategory.bottom;
      case 2:
        return ClothingCategory.outerwear;
      case 3:
        return ClothingCategory.shoes;
      default:
        return ClothingCategory.top;
    }
  }

  @override
  void write(BinaryWriter writer, ClothingCategory obj) {
    switch (obj) {
      case ClothingCategory.top:
        writer.writeByte(0);
        break;
      case ClothingCategory.bottom:
        writer.writeByte(1);
        break;
      case ClothingCategory.outerwear:
        writer.writeByte(2);
        break;
      case ClothingCategory.shoes:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothingCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
