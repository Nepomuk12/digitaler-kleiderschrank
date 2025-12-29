import 'package:hive/hive.dart';
import '../domain/clothing_item_hive.dart';
import 'dart:io';

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
Future<void> deleteItem(String id) async {
  final item = _box.get(id);
  if (item != null) {
    // Datei löschen (wenn vorhanden)
    try {
      final f = File(item.normalizedImagePath);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {
      // ignorieren (z.B. Datei bereits weg)
    }
  }
  await _box.delete(id);
}
Future<void> upsertItem(ClothingItem item) async {
  await _box.put(item.id, item);
}

}
