import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/clothing_repository.dart';
import '../../domain/clothing_item_hive.dart';
import '../../services/image_normalizer.dart';

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
    ColorTag? color,
    TopType? topType,
    BottomType? bottomType,
    ShoeType? shoeType,
    String? brandNotes, // <-- NEU
  }) async {
    state = const AsyncLoading();
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 95,
      );

      if (picked == null) {
        state = const AsyncData(null);
        return;
      }

      final cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Zuschneiden',
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
        ],
      );

      if (cropped == null) {
        state = const AsyncData(null);
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${dir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final id = _uuid.v4();

      final rawPath = '${imagesDir.path}/${id}_raw.jpg';
      await File(cropped.path).copy(rawPath);

      final normalizedPath = '${imagesDir.path}/${id}_norm.jpg';
      await ImageNormalizer.resizeToMaxPixels(
        input: File(rawPath),
        output: File(normalizedPath),
        maxPixels: 2000000,
        jpegQuality: 85,
      );

      final cleanedBrandNotes =
          (brandNotes == null || brandNotes.trim().isEmpty) ? null : brandNotes.trim();

      final item = ClothingItem(
        id: id,
        category: category,
        imagePath: normalizedPath, // Übergang/Legacy
        rawImagePath: rawPath,
        normalizedImagePath: normalizedPath,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        tags: const [],
        color: color,
        topType: topType,
        bottomType: bottomType,
        shoeType: shoeType,
        brandNotes: cleanedBrandNotes, // <-- NEU
      );

      await _repo.insertItem(item);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
