import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/clothing_item_hive.dart';
import '../../domain/tag_labels.dart';
import 'add_item_controller.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  ClothingCategory category = ClothingCategory.top;

  ColorTag? selectedColor;
  TopType? selectedTopType;
  BottomType? selectedBottomType;
  ShoeType? selectedShoeType;

  final TextEditingController _brandNotesCtrl = TextEditingController();

  @override
  void dispose() {
    _brandNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addItemControllerProvider);

    ref.listen(addItemControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        ),
      );
    });

    Widget typeDropdown() {
      switch (category) {
        case ClothingCategory.top:
          return DropdownButtonFormField<TopType>(
            value: selectedTopType,
            items: TopType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(topTypeLabel(t)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => selectedTopType = v),
            decoration: const InputDecoration(
              labelText: 'Typ (Oberteil)',
              border: OutlineInputBorder(),
            ),
          );

        case ClothingCategory.bottom:
          return DropdownButtonFormField<BottomType>(
            value: selectedBottomType,
            items: BottomType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(bottomTypeLabel(t)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => selectedBottomType = v),
            decoration: const InputDecoration(
              labelText: 'Typ (Unterteil)',
              border: OutlineInputBorder(),
            ),
          );

        case ClothingCategory.shoes:
          return DropdownButtonFormField<ShoeType>(
            value: selectedShoeType,
            items: ShoeType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(shoeTypeLabel(t)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => selectedShoeType = v),
            decoration: const InputDecoration(
              labelText: 'Typ (Schuhe)',
              border: OutlineInputBorder(),
            ),
          );

        case ClothingCategory.outerwear:
          return const SizedBox.shrink();
      }
    }

    // Optionales Preview vom letzten Item (nur wenn im Repo vorhanden)
    final latest = ref.read(clothingRepoProvider).latestItem();

    Future<void> add(ImageSource source) async {
      await ref.read(addItemControllerProvider.notifier).addItem(
            category: category,
            source: source,
            color: selectedColor,
            topType: selectedTopType,
            bottomType: selectedBottomType,
            shoeType: selectedShoeType,
            brandNotes: _brandNotesCtrl.text.trim().isEmpty
                ? null
                : _brandNotesCtrl.text.trim(),
          );

      // Komfort: Feld nach erfolgreichem Speichern leeren
      if (mounted) {
        _brandNotesCtrl.clear();
      }
    }

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Kleidung hinzufügen',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),

                    // Kategorie
                    DropdownButtonFormField<ClothingCategory>(
                      value: category,
                      items: ClothingCategory.values
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(categoryLabel(c)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() {
                        category = v ?? category;
                        selectedTopType = null;
                        selectedBottomType = null;
                        selectedShoeType = null;
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Kategorie',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Farbe
                    DropdownButtonFormField<ColorTag>(
                      value: selectedColor,
                      items: ColorTag.values
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(colorLabel(c)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedColor = v),
                      decoration: const InputDecoration(
                        labelText: 'Farbe',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Typ (abhängig von Kategorie)
                    typeDropdown(),

                    const SizedBox(height: 12),

                    // Marke/Notizen
                    TextField(
                      controller: _brandNotesCtrl,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Marke/Notizen',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Optional Preview
                    if (latest != null) ...[
                      SizedBox(
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(latest.normalizedImagePath),
                            fit: BoxFit.cover,
                            cacheWidth: 900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Kamera
                    ElevatedButton.icon(
                      onPressed:
                          state.isLoading ? null : () => add(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Mit Kamera fotografieren'),
                    ),

                    const SizedBox(height: 8),

                    // Galerie
                    OutlinedButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => add(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Aus Galerie wählen'),
                    ),

                    const SizedBox(height: 16),
                    if (state.isLoading) const LinearProgressIndicator(),

                    const Spacer(),
                    const Text(
                      'V: Filter Outfitscreen (c) 251230 C.Bohne',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
