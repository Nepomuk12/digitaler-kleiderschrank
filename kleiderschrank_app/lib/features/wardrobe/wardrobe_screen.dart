import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/tag_labels.dart';
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
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => _EditItemSheet(item: it),
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
                    File(it.normalizedImagePath),
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
class _EditItemSheet extends ConsumerStatefulWidget {
  const _EditItemSheet({required this.item});

  final ClothingItem item;

  @override
  ConsumerState<_EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends ConsumerState<_EditItemSheet> {
  late ClothingCategory category;
  ColorTag? color;
  TopType? topType;
  BottomType? bottomType;
  ShoeType? shoeType;

  @override
  void initState() {
    super.initState();
    category = widget.item.category;
    color = widget.item.color;
    topType = widget.item.topType;
    bottomType = widget.item.bottomType;
    shoeType = widget.item.shoeType;
  }

  Widget _typeDropdown() {
    switch (category) {
      case ClothingCategory.top:
        return DropdownButtonFormField<TopType>(
          value: topType,
          items: TopType.values
              .map((t) => DropdownMenuItem(value: t, child: Text(topTypeLabel(t))))
              .toList(),
          onChanged: (v) => setState(() => topType = v),
          decoration: const InputDecoration(
            labelText: 'Typ (Oberteil)',
            border: OutlineInputBorder(),
          ),
        );
      case ClothingCategory.bottom:
        return DropdownButtonFormField<BottomType>(
          value: bottomType,
          items: BottomType.values
              .map((t) => DropdownMenuItem(value: t, child: Text(bottomTypeLabel(t))))
              .toList(),
          onChanged: (v) => setState(() => bottomType = v),
          decoration: const InputDecoration(
            labelText: 'Typ (Unterteil)',
            border: OutlineInputBorder(),
          ),
        );
      case ClothingCategory.shoes:
        return DropdownButtonFormField<ShoeType>(
          value: shoeType,
          items: ShoeType.values
              .map((t) => DropdownMenuItem(value: t, child: Text(shoeTypeLabel(t))))
              .toList(),
          onChanged: (v) => setState(() => shoeType = v),
          decoration: const InputDecoration(
            labelText: 'Typ (Schuhe)',
            border: OutlineInputBorder(),
          ),
        );
      case ClothingCategory.outerwear:
        return const SizedBox.shrink(); // später outerwearType
    }
  }

  void _clearTypesForCategory() {
    topType = null;
    bottomType = null;
    shoeType = null;
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(clothingRepoProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kategorie
          DropdownButtonFormField<ClothingCategory>(
            value: category,
            items: ClothingCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(categoryLabel(c))))
                .toList(),
            onChanged: (v) => setState(() {
              category = v ?? category;
              _clearTypesForCategory();
            }),
            decoration: const InputDecoration(
              labelText: 'Kategorie',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Farbe
          DropdownButtonFormField<ColorTag>(
            value: color,
            items: ColorTag.values
                .map((c) => DropdownMenuItem(value: c, child: Text(colorLabel(c))))
                .toList(),
            onChanged: (v) => setState(() => color = v),
            decoration: const InputDecoration(
              labelText: 'Farbe',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Typ (abhängig von Kategorie)
          _typeDropdown(),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Löschen'),
                  onPressed: () async {
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
                      await repo.deleteItem(widget.item.id);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Speichern'),
                  onPressed: () async {
             final updated = ClothingItem(
              id: widget.item.id,
              category: category,

              // Übergang
              imagePath: widget.item.normalizedImagePath,

              // Pflichtfelder korrekt weiterreichen
              rawImagePath: widget.item.rawImagePath,
              normalizedImagePath: widget.item.normalizedImagePath,

              createdAt: widget.item.createdAt,
              tags: widget.item.tags,
              color: color,
              topType: topType,
              bottomType: bottomType,
              shoeType: shoeType,
            );



                    await repo.upsertItem(updated);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
