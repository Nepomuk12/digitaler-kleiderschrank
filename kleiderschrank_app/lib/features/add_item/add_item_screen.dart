import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/clothing_item_hive.dart';
import '../../domain/tag_labels.dart';
import 'add_item_controller.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../services/image_normalizer.dart';


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
          // Outerwear-Typen kommen später; vorerst kein Typ-Dropdown.
          return const SizedBox.shrink();
      }
    }

    // Optionales Preview vom letzten Item (nur wenn du es bereits eingebaut hast)
    final latest = ref.read(clothingRepoProvider).latestItem();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kleidung hinzufügen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Kategorie
            DropdownButtonFormField<ClothingCategory>(
              value: category,
              items: ClothingCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(categoryLabel(c)), // <- statt c.name
                      ))
                  .toList(),
              onChanged: (v) => setState(() {
                category = v ?? category;
                // Typ-Auswahl zurücksetzen, damit nichts „falsch“ hängen bleibt
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

            const SizedBox(height: 16),

            // Optional: Preview vom letzten Item (wenn latestItem() im Repo vorhanden ist)
            if (latest != null) ...[
              SizedBox(
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(latest.normalizedImagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Kamera
            ElevatedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => ref.read(addItemControllerProvider.notifier).addItem(
                        category: category,
                        source: ImageSource.camera,
                        color: selectedColor,
                        topType: selectedTopType,
                        bottomType: selectedBottomType,
                        shoeType: selectedShoeType,
                      ),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Mit Kamera fotografieren'),
            ),

            const SizedBox(height: 8),

            // Galerie
            OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => ref.read(addItemControllerProvider.notifier).addItem(
                        category: category,
                        source: ImageSource.gallery,
                        color: selectedColor,
                        topType: selectedTopType,
                        bottomType: selectedBottomType,
                        shoeType: selectedShoeType,
                      ),
              icon: const Icon(Icons.photo_library),
              label: const Text('Aus Galerie wählen'),
            ),

            const SizedBox(height: 16),
            if (state.isLoading) const LinearProgressIndicator(),

            const Spacer(),
            const Text(
              'MVP+: Foto + Kategorie + Farbe + Typ speichern (Hive).',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
