import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/clothing_repository.dart';
import '../../domain/clothing_item_hive.dart';

final clothingRepoProvider = Provider<ClothingRepository>((ref) {
  return ClothingRepository();
});

final addItemControllerProvider =
    StateNotifierProvider<AddItemController, AsyncValue<void>>((ref) {
  return AddItemController(ref.read(clothingRepoProvider));
});

class AddItemController extends StateNotifier<AsyncValue<void>> {
  AddItemController(this._repo) : super(const AsyncData(null));

  final ClothingRepository _repo;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  Future<void> addItem({
    required ClothingCategory category,
    required ImageSource source,
  }) async {
    state = const AsyncLoading();
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (picked == null) {
        state = const AsyncData(null);
        return;
      }

      // Ziel: Bild dauerhaft in App-Speicher ablegen
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final id = _uuid.v4();
      final newPath = '${imagesDir.path}/$id.jpg';

      await File(picked.path).copy(newPath);

      final item = ClothingItem(
        id: id,
        category: category,
        imagePath: newPath,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        tags: const [],
      );

      await _repo.insertItem(item);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
