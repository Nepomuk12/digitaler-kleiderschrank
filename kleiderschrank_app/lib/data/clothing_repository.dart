import 'package:hive/hive.dart';
import '../domain/clothing_item_hive.dart';

class ClothingRepository {
  Box<ClothingItem> get _box => Hive.box<ClothingItem>('clothing_items');

  Future<void> insertItem(ClothingItem item) async {
    await _box.put(item.id, item);
  }

  List<ClothingItem> loadByCategory(ClothingCategory category) {
    final items = _box.values.where((e) => e.category == category).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<ClothingItem> loadAll() {
    final items = _box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }
  
  ClothingItem? latestItem() {
  if (_box.isEmpty) return null;
  final items = _box.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return items.first;
}

}
