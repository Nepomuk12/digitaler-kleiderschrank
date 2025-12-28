import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/clothing_item_hive.dart';
import 'add_item_controller.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

String categoryLabel(ClothingCategory c) {
  switch (c) {
    case ClothingCategory.top:
      return 'Oberteile (inkl. Kleider)';
    case ClothingCategory.bottom:
      return 'Unterteile (inkl. Strumpfhosen)';
    case ClothingCategory.outerwear:
      return 'Jacken / Mäntel';
    case ClothingCategory.shoes:
      return 'Schuhe / Stiefel';
  }
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  ClothingCategory category = ClothingCategory.top;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addItemControllerProvider);
    final latest = ref.read(clothingRepoProvider).latestItem();


    ref.listen(addItemControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        ),
      );
      if (next is AsyncData) {
        // optional: Erfolgsmeldung, aber nur wenn gerade nicht loading
      }
    });

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

            if (latest != null) ...[
              const Text('Letztes Item:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(latest.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            DropdownButtonFormField<ClothingCategory>(
              value: category,
              items: ClothingCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(categoryLabel(c)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => category = v ?? category),
              decoration: const InputDecoration(
                labelText: 'Kategorie',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => ref.read(addItemControllerProvider.notifier).addItem(
                        category: category,
                        source: ImageSource.camera,
                      ),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Mit Kamera fotografieren'),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => ref.read(addItemControllerProvider.notifier).addItem(
                        category: category,
                        source: ImageSource.gallery,
                      ),
              icon: const Icon(Icons.photo_library),
              label: const Text('Aus Galerie wählen'),
            ),

            const SizedBox(height: 16),
            if (state.isLoading) const LinearProgressIndicator(),
            
            const Spacer(),
            const Text(
              'MVP: Foto + Kategorie speichern (Hive).',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
