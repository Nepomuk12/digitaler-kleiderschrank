import 'package:hive/hive.dart';

part 'clothing_item_hive.g.dart';

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



@HiveType(typeId: 2)
class ClothingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ClothingCategory category;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final int createdAt;

  @HiveField(4)
  final List<String> tags;

  ClothingItem({
    required this.id,
    required this.category,
    required this.imagePath,
    required this.createdAt,
    this.tags = const [],
  });
}
