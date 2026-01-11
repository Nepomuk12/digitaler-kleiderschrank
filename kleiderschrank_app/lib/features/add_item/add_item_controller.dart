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
    StateNotifierProvider<AddItemController, AddItemState>((ref) {
  return AddItemController(ref.read(clothingRepoProvider));
});

/// 🔹 State enthält jetzt auch Bildpfade
class AddItemState {
  final bool loading;
  final String? rawPath;
  final String? normalizedPath;

  const AddItemState({
    this.loading = false,
    this.rawPath,
    this.normalizedPath,
  });

  bool get hasImage => rawPath != null && normalizedPath != null;
}

class AddItemController extends StateNotifier<AddItemState> {
  AddItemController(this._repo) : super(const AddItemState());

  final ClothingRepository _repo;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// 📸 Schritt 1: Bild aufnehmen / wählen
  Future<void> pickImage(ImageSource source) async {
    state = const AddItemState(loading: true);

    final picked = await _picker.pickImage(source: source, imageQuality: 95);
    if (picked == null) {
      state = const AddItemState();
      return;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Zuschneiden',
          lockAspectRatio: false,
        ),
      ],
    );

    if (cropped == null) {
      state = const AddItemState();
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final id = _uuid.v4();
    final rawPath = '${imagesDir.path}/${id}_raw.jpg';
    final normPath = '${imagesDir.path}/${id}_norm.jpg';

    await File(cropped.path).copy(rawPath);

    await ImageNormalizer.resizeToMaxPixels(
      input: File(rawPath),
      output: File(normPath),
      maxPixels: 1200000,
      jpegQuality: 80,
    );

    state = AddItemState(
      loading: false,
      rawPath: rawPath,
      normalizedPath: normPath,
    );
  }

  /// 💾 Schritt 4: Item speichern
  Future<void> saveItem({
    required ClothingCategory category,
    ColorTag? color,
    TopType? topType,
    BottomType? bottomType,
    ShoeType? shoeType,
    List<OutfitOccasion> occasions = const [],
    String? brandNotes,
  }) async {
    if (!state.hasImage) return;

    final id = _uuid.v4();
    final isOutfit = category == ClothingCategory.outfit;

    final item = ClothingItem(
      id: id,
      category: category,
      imagePath: state.normalizedPath!,
      rawImagePath: state.rawPath!,
      normalizedImagePath: state.normalizedPath!,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      tags: const [],
      color: isOutfit ? null : color,
      topType: category == ClothingCategory.top ? topType : null,
      bottomType: category == ClothingCategory.bottom ? bottomType : null,
      shoeType: category == ClothingCategory.shoes ? shoeType : null,
      brandNotes: brandNotes,
      occasions: isOutfit ? occasions : const [],
    );

    await _repo.insertItem(item);

    // Reset für nächstes Item
    state = const AddItemState();
  }

  void reset() {
    state = const AddItemState();
  }
}
