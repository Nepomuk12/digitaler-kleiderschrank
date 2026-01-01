import 'package:hive/hive.dart';

part 'clothing_item_hive.g.dart';

/// Kategorien (final, ohne "dress")
@HiveType(typeId: 1)
enum ClothingCategory {
  @HiveField(0)
  top,

  @HiveField(1)
  bottom,

  @HiveField(2)
  outerwear,

  @HiveField(3)
  shoes,
}

/// Tag 1: Farbe (inkl. Muster/Mehrfarbig)
@HiveType(typeId: 3)
enum ColorTag {
  @HiveField(0)
  black, // Schwarz
  @HiveField(1)
  white, // Weiß
  @HiveField(2)
  grey, // Grau
  @HiveField(3)
  beige, // Beige/Nude
  @HiveField(4)
  brown, // Braun
  @HiveField(5)
  blue, // Blau/Navy
  @HiveField(6)
  green, // Grün
  @HiveField(7)
  red, // Rot
  @HiveField(8)
  bordeauxViolet, // Bordeaux/Violett
  @HiveField(9)
  pink, // Rosa/Pink
  @HiveField(10)
  yellow, // Gelb
  @HiveField(11)
  orange, // Orange
  @HiveField(12)
  metallic, // Metallic (Gold/Silber)
  @HiveField(13)
  denim, // Denim/Jeansblau
  @HiveField(14)
  multicolor, // Mehrfarbig
  @HiveField(15)
  pattern, // Muster (Streifen/Karo/Blumen/Punkte)
}

/// Tag 2: Typ (je Kategorie)
/// Oberteile (inkl. Kleider)
@HiveType(typeId: 4)
enum TopType {
  @HiveField(0)
  tshirt, // T-Shirt
  @HiveField(1)
  PoloShirt, // Polo-Shirt
  @HiveField(2)
  blouse, // Bluse
  @HiveField(3)
  shirt, // Hemd
  @HiveField(4)
  tankTop, // Top/Träger
  @HiveField(5)
  longsleeve, // Longsleeve
  @HiveField(6)
  sweater, // Pullover
  @HiveField(7)
  hoodie, // Hoodie
  @HiveField(8)
  cardigan, // Strickjacke/Cardigan
  @HiveField(9)
  blazer, // Blazer
  @HiveField(10)
  tunic, // Tunika
  @HiveField(111)
  turtleneck, // Rollkragen
  @HiveField(12)
  cropTop, // Crop-Top
  @HiveField(13)
  body, // Body
  @HiveField(14)
  dressShort, // Kleid (kurz)
  @HiveField(15)
  dressLong, // Kleid (lang)
  @HiveField(16)
  jumpsuit, // Jumpsuit/Overall
  @HiveField(17)
  coordTop, // Set/Oberteil (Co-Ord)
  @HiveField(18)
  sportsTop, // Sporttop
  @HiveField(19)
  tank, // Tanktop
  @HiveField(20)
  clubwear, // Clubwear, Kinky Outfits
  @HiveField(21)
  homewear, // Tops for Home Dresses & Loungewear
  @HiveField(22)
  other, // Sonstiges
}

/// Unterteile (inkl. Strumpfhosen)
@HiveType(typeId: 5)
enum BottomType {
  @HiveField(0)
  jeans, // Jeans
  @HiveField(1)
  trousers, // Stoffhose
  @HiveField(2)
  chino, // Chino
  @HiveField(3)
  leggings, // Leggings
  @HiveField(4)
  tights, // Strumpfhose
  @HiveField(5)
  joggers, // Jogginghose
  @HiveField(6)
  shorts, // Shorts
  @HiveField(7)
  bikerShorts, // Radler/Biker Shorts
  @HiveField(8)
  skirtMini, // Rock (mini)
  @HiveField(9)
  skirtMidi, // Rock (midi)
  @HiveField(10)
  skirtMaxi, // Rock (maxi)
  @HiveField(11)
  culotte, // Culotte
  @HiveField(12)
  palazzo, // Palazzo
  @HiveField(13)
  cargo, // Cargo
  @HiveField(14)
  leatherLook, // Lederhose/Imitat
  @HiveField(15)
  suitTrousers, // Anzughose
  @HiveField(16)
  sportsPants, // Sporthose
  @HiveField(17)
  thermoPants, // Thermohose
  @HiveField(18)
  coordBottom, // Set/Unterteil (Co-Ord)
  @HiveField(19)
  CroppedTrouser, // 7/8-Hose
  @HiveField(20)
  clubwear, // Clubwear, Kinky Outfits
  @HiveField(21)
  homewear, // Bottom fpr Home Dresses & Loungewear
  @HiveField(22) 
  other, // Sonstiges
}

/// Schuhe
@HiveType(typeId: 6)
enum ShoeType {
  @HiveField(0)
  sneakers, // Sneaker
  @HiveField(1)
  boots, // Stiefel
  @HiveField(2)
  ankleBoots, // Stiefelette/Boots
  @HiveField(3)
  heels, // High Heels/Pumps
  @HiveField(4)
  sandals, // Sandalen
  @HiveField(5)
  ballerinas, // Ballerinas
  @HiveField(6)
  loafers, // Loafer
  @HiveField(7)
  slippers, // Slipper
  @HiveField(8)
  laceUps, // Schnürschuhe
  @HiveField(9)
  chelseaBoots, // Chelsea Boots
  @HiveField(10)
  overknee, // Overknee
  @HiveField(11)
  platform, // Plateau
  @HiveField(12)
  wedges, // Wedges/Keilabsatz
  @HiveField(13)
  flipFlops, // Flip-Flops
  @HiveField(14)
  houseShoes, // Hausschuhe
  @HiveField(15)
  sportShoes, // Sportschuhe
  @HiveField(16)
  hikingShoes, // Wanderschuhe
  @HiveField(17)
  businessShoes, // Business-Schuhe
  @HiveField(18)
  flatSummerSandals, // Sommersandale flach
  @HiveField(19)
  other, // Sonstiges
}

/// Clothing Item (Hive persisted)
@HiveType(typeId: 2)
class ClothingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ClothingCategory category;

  /// Lokaler Dateipfad (Android/iOS). Für Web würdest du alternativ bytes speichern.
  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final int createdAt;

  /// Freitext-Tags (optional, später). Strukturierte Tags sind unten als Felder.
  @HiveField(4)
  final List<String> tags;

  /// Strukturierte Tags
  @HiveField(5)
  final ColorTag? color;

  @HiveField(6)
  final TopType? topType;

  @HiveField(7)
  final BottomType? bottomType;

  @HiveField(8)
  final ShoeType? shoeType;

  @HiveField(9)
  final String? rawImagePath;

  @HiveField(10)
  final String normalizedImagePath;

  /// Freitext: Marke / Besonderheiten (ein Feld)
  @HiveField(11)
  final String? brandNotes;

  ClothingItem({
    required this.id,
    required this.category,
    required this.imagePath,
    required this.createdAt,
    this.tags = const [],
    this.color,
    this.topType,
    this.bottomType,
    this.shoeType,
    this.rawImagePath,
    required this.normalizedImagePath,
    this.brandNotes,
  });
}
