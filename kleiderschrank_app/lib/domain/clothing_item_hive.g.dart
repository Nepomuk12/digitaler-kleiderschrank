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
      color: fields[5] as ColorTag?,
      topType: fields[6] as TopType?,
      bottomType: fields[7] as BottomType?,
      shoeType: fields[8] as ShoeType?,
      rawImagePath: fields[9] as String?,
      normalizedImagePath: fields[10] as String,
      brandNotes: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClothingItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.topType)
      ..writeByte(7)
      ..write(obj.bottomType)
      ..writeByte(8)
      ..write(obj.shoeType)
      ..writeByte(9)
      ..write(obj.rawImagePath)
      ..writeByte(10)
      ..write(obj.normalizedImagePath)
      ..writeByte(11)
      ..write(obj.brandNotes);
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

class ColorTagAdapter extends TypeAdapter<ColorTag> {
  @override
  final int typeId = 3;

  @override
  ColorTag read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ColorTag.black;
      case 1:
        return ColorTag.white;
      case 2:
        return ColorTag.grey;
      case 3:
        return ColorTag.beige;
      case 4:
        return ColorTag.brown;
      case 5:
        return ColorTag.blue;
      case 6:
        return ColorTag.green;
      case 7:
        return ColorTag.red;
      case 8:
        return ColorTag.bordeauxViolet;
      case 9:
        return ColorTag.pink;
      case 10:
        return ColorTag.yellow;
      case 11:
        return ColorTag.orange;
      case 12:
        return ColorTag.metallic;
      case 13:
        return ColorTag.denim;
      case 14:
        return ColorTag.multicolor;
      case 15:
        return ColorTag.pattern;
      default:
        return ColorTag.black;
    }
  }

  @override
  void write(BinaryWriter writer, ColorTag obj) {
    switch (obj) {
      case ColorTag.black:
        writer.writeByte(0);
        break;
      case ColorTag.white:
        writer.writeByte(1);
        break;
      case ColorTag.grey:
        writer.writeByte(2);
        break;
      case ColorTag.beige:
        writer.writeByte(3);
        break;
      case ColorTag.brown:
        writer.writeByte(4);
        break;
      case ColorTag.blue:
        writer.writeByte(5);
        break;
      case ColorTag.green:
        writer.writeByte(6);
        break;
      case ColorTag.red:
        writer.writeByte(7);
        break;
      case ColorTag.bordeauxViolet:
        writer.writeByte(8);
        break;
      case ColorTag.pink:
        writer.writeByte(9);
        break;
      case ColorTag.yellow:
        writer.writeByte(10);
        break;
      case ColorTag.orange:
        writer.writeByte(11);
        break;
      case ColorTag.metallic:
        writer.writeByte(12);
        break;
      case ColorTag.denim:
        writer.writeByte(13);
        break;
      case ColorTag.multicolor:
        writer.writeByte(14);
        break;
      case ColorTag.pattern:
        writer.writeByte(15);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TopTypeAdapter extends TypeAdapter<TopType> {
  @override
  final int typeId = 4;

  @override
  TopType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TopType.tshirt;
      case 1:
        return TopType.PoloShirt;
      case 2:
        return TopType.blouse;
      case 3:
        return TopType.shirt;
      case 4:
        return TopType.tankTop;
      case 5:
        return TopType.longsleeve;
      case 6:
        return TopType.sweater;
      case 7:
        return TopType.hoodie;
      case 8:
        return TopType.cardigan;
      case 9:
        return TopType.blazer;
      case 10:
        return TopType.tunic;
      case 111:
        return TopType.turtleneck;
      case 12:
        return TopType.cropTop;
      case 13:
        return TopType.body;
      case 14:
        return TopType.dressShort;
      case 15:
        return TopType.dressLong;
      case 16:
        return TopType.jumpsuit;
      case 17:
        return TopType.coordTop;
      case 18:
        return TopType.sportsTop;
      case 19:
        return TopType.tank;
      case 20:
        return TopType.clubwear;
      case 21:
        return TopType.homewear;
      case 22:
        return TopType.other;
      default:
        return TopType.tshirt;
    }
  }

  @override
  void write(BinaryWriter writer, TopType obj) {
    switch (obj) {
      case TopType.tshirt:
        writer.writeByte(0);
        break;
      case TopType.PoloShirt:
        writer.writeByte(1);
        break;
      case TopType.blouse:
        writer.writeByte(2);
        break;
      case TopType.shirt:
        writer.writeByte(3);
        break;
      case TopType.tankTop:
        writer.writeByte(4);
        break;
      case TopType.longsleeve:
        writer.writeByte(5);
        break;
      case TopType.sweater:
        writer.writeByte(6);
        break;
      case TopType.hoodie:
        writer.writeByte(7);
        break;
      case TopType.cardigan:
        writer.writeByte(8);
        break;
      case TopType.blazer:
        writer.writeByte(9);
        break;
      case TopType.tunic:
        writer.writeByte(10);
        break;
      case TopType.turtleneck:
        writer.writeByte(111);
        break;
      case TopType.cropTop:
        writer.writeByte(12);
        break;
      case TopType.body:
        writer.writeByte(13);
        break;
      case TopType.dressShort:
        writer.writeByte(14);
        break;
      case TopType.dressLong:
        writer.writeByte(15);
        break;
      case TopType.jumpsuit:
        writer.writeByte(16);
        break;
      case TopType.coordTop:
        writer.writeByte(17);
        break;
      case TopType.sportsTop:
        writer.writeByte(18);
        break;
      case TopType.tank:
        writer.writeByte(19);
        break;
      case TopType.clubwear:
        writer.writeByte(20);
        break;
      case TopType.homewear:
        writer.writeByte(21);
        break;
      case TopType.other:
        writer.writeByte(22);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BottomTypeAdapter extends TypeAdapter<BottomType> {
  @override
  final int typeId = 5;

  @override
  BottomType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BottomType.jeans;
      case 1:
        return BottomType.trousers;
      case 2:
        return BottomType.chino;
      case 3:
        return BottomType.leggings;
      case 4:
        return BottomType.tights;
      case 5:
        return BottomType.joggers;
      case 6:
        return BottomType.shorts;
      case 7:
        return BottomType.bikerShorts;
      case 8:
        return BottomType.skirtMini;
      case 9:
        return BottomType.skirtMidi;
      case 10:
        return BottomType.skirtMaxi;
      case 11:
        return BottomType.culotte;
      case 12:
        return BottomType.palazzo;
      case 13:
        return BottomType.cargo;
      case 14:
        return BottomType.leatherLook;
      case 15:
        return BottomType.suitTrousers;
      case 16:
        return BottomType.sportsPants;
      case 17:
        return BottomType.thermoPants;
      case 18:
        return BottomType.coordBottom;
      case 19:
        return BottomType.CroppedTrouser;
      case 20:
        return BottomType.clubwear;
      case 21:
        return BottomType.homewear;
      case 22:
        return BottomType.other;
      default:
        return BottomType.jeans;
    }
  }

  @override
  void write(BinaryWriter writer, BottomType obj) {
    switch (obj) {
      case BottomType.jeans:
        writer.writeByte(0);
        break;
      case BottomType.trousers:
        writer.writeByte(1);
        break;
      case BottomType.chino:
        writer.writeByte(2);
        break;
      case BottomType.leggings:
        writer.writeByte(3);
        break;
      case BottomType.tights:
        writer.writeByte(4);
        break;
      case BottomType.joggers:
        writer.writeByte(5);
        break;
      case BottomType.shorts:
        writer.writeByte(6);
        break;
      case BottomType.bikerShorts:
        writer.writeByte(7);
        break;
      case BottomType.skirtMini:
        writer.writeByte(8);
        break;
      case BottomType.skirtMidi:
        writer.writeByte(9);
        break;
      case BottomType.skirtMaxi:
        writer.writeByte(10);
        break;
      case BottomType.culotte:
        writer.writeByte(11);
        break;
      case BottomType.palazzo:
        writer.writeByte(12);
        break;
      case BottomType.cargo:
        writer.writeByte(13);
        break;
      case BottomType.leatherLook:
        writer.writeByte(14);
        break;
      case BottomType.suitTrousers:
        writer.writeByte(15);
        break;
      case BottomType.sportsPants:
        writer.writeByte(16);
        break;
      case BottomType.thermoPants:
        writer.writeByte(17);
        break;
      case BottomType.coordBottom:
        writer.writeByte(18);
        break;
      case BottomType.CroppedTrouser:
        writer.writeByte(19);
        break;
      case BottomType.clubwear:
        writer.writeByte(20);
        break;
      case BottomType.homewear:
        writer.writeByte(21);
        break;
      case BottomType.other:
        writer.writeByte(22);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BottomTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShoeTypeAdapter extends TypeAdapter<ShoeType> {
  @override
  final int typeId = 6;

  @override
  ShoeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShoeType.sneakers;
      case 1:
        return ShoeType.boots;
      case 2:
        return ShoeType.ankleBoots;
      case 3:
        return ShoeType.heels;
      case 4:
        return ShoeType.sandals;
      case 5:
        return ShoeType.ballerinas;
      case 6:
        return ShoeType.loafers;
      case 7:
        return ShoeType.slippers;
      case 8:
        return ShoeType.laceUps;
      case 9:
        return ShoeType.chelseaBoots;
      case 10:
        return ShoeType.overknee;
      case 11:
        return ShoeType.platform;
      case 12:
        return ShoeType.wedges;
      case 13:
        return ShoeType.flipFlops;
      case 14:
        return ShoeType.houseShoes;
      case 15:
        return ShoeType.sportShoes;
      case 16:
        return ShoeType.hikingShoes;
      case 17:
        return ShoeType.businessShoes;
      case 18:
        return ShoeType.flatSummerSandals;
      case 19:
        return ShoeType.other;
      default:
        return ShoeType.sneakers;
    }
  }

  @override
  void write(BinaryWriter writer, ShoeType obj) {
    switch (obj) {
      case ShoeType.sneakers:
        writer.writeByte(0);
        break;
      case ShoeType.boots:
        writer.writeByte(1);
        break;
      case ShoeType.ankleBoots:
        writer.writeByte(2);
        break;
      case ShoeType.heels:
        writer.writeByte(3);
        break;
      case ShoeType.sandals:
        writer.writeByte(4);
        break;
      case ShoeType.ballerinas:
        writer.writeByte(5);
        break;
      case ShoeType.loafers:
        writer.writeByte(6);
        break;
      case ShoeType.slippers:
        writer.writeByte(7);
        break;
      case ShoeType.laceUps:
        writer.writeByte(8);
        break;
      case ShoeType.chelseaBoots:
        writer.writeByte(9);
        break;
      case ShoeType.overknee:
        writer.writeByte(10);
        break;
      case ShoeType.platform:
        writer.writeByte(11);
        break;
      case ShoeType.wedges:
        writer.writeByte(12);
        break;
      case ShoeType.flipFlops:
        writer.writeByte(13);
        break;
      case ShoeType.houseShoes:
        writer.writeByte(14);
        break;
      case ShoeType.sportShoes:
        writer.writeByte(15);
        break;
      case ShoeType.hikingShoes:
        writer.writeByte(16);
        break;
      case ShoeType.businessShoes:
        writer.writeByte(17);
        break;
      case ShoeType.flatSummerSandals:
        writer.writeByte(18);
        break;
      case ShoeType.other:
        writer.writeByte(19);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
