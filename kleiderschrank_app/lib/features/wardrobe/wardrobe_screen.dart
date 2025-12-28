import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/clothing_item_hive.dart';
import '../add_item/add_item_controller.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(clothingRepoProvider);

    // Reaktiv: aktualisiert UI automatisch bei Änderungen
    final box = Hive.box<ClothingItem>('clothing_items');

    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<ClothingItem> b, _) {
          final items = b.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final it = items[i];

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      insetPadding: const EdgeInsets.all(12),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Image.file(File(it.imagePath), fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
                onLongPress: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Löschen?'),
                      content: const Text('Item und Foto werden gelöscht.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Abbrechen'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Löschen'),
                        ),
                      ],
                    ),
                  );

                  if (ok == true) {
                    await repo.deleteItem(it.id);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(it.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
