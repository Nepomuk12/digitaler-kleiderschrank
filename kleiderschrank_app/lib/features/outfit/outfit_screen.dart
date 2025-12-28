import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/clothing_item_hive.dart';
import '../add_item/add_item_controller.dart';

class OutfitScreen extends ConsumerWidget {
  const OutfitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(clothingRepoProvider);
    final tops = repo.loadByCategory(ClothingCategory.top);
    final bottoms = repo.loadByCategory(ClothingCategory.bottom);
    final outerwears = repo.loadByCategory(ClothingCategory.outerwear);
    final shoes = repo.loadByCategory(ClothingCategory.shoes);


    Widget section(String title, List<ClothingItem> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title (${items.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('Keine Items')
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final it = items[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(it.imagePath),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Outfit – Datenbank Check',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          section('Oberteile (inkl. Kleider)', tops),
          section('Unterteile (inkl. Strumpfhosen)', bottoms),
          section('Jacken/Mäntel', outerwears),
          section('Schuhe/Stiefel', shoes),
          const Text(
            'Wenn du hier deine Fotos siehst: Hive-Lesen funktioniert. Als nächstes bauen wir Swipen pro Slot.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
