import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/clothing_item_hive.dart';
import '../../domain/tag_labels.dart';
import '../add_item/add_item_controller.dart';

class OutfitScreen extends ConsumerStatefulWidget {
  const OutfitScreen({super.key});

  @override
  ConsumerState<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends ConsumerState<OutfitScreen> {
  int topIndex = 0;
  int bottomIndex = 0;
  int shoesIndex = 0;

  // Filter
  TopType? topType;
  ColorTag? topColor;

  BottomType? bottomType;
  ColorTag? bottomColor;

  ShoeType? shoeType;
  ColorTag? shoesColor;

  // vorbereitet, aber deaktiviert
  bool showOuterwear = false;

  int _wrap(int i, int len) {
    if (len <= 0) return 0;
    final r = i % len;
    return r < 0 ? r + len : r;
  }

  ClothingItem? _current(List<ClothingItem> list, int index) =>
      list.isEmpty ? null : list[index];

  List<ClothingItem> _filterTops(List<ClothingItem> items) {
    return items.where((it) {
      if (topType != null && it.topType != topType) return false;
      if (topColor != null && it.color != topColor) return false;
      return true;
    }).toList();
  }

  List<ClothingItem> _filterBottoms(List<ClothingItem> items) {
    return items.where((it) {
      if (bottomType != null && it.bottomType != bottomType) return false;
      if (bottomColor != null && it.color != bottomColor) return false;
      return true;
    }).toList();
  }

  List<ClothingItem> _filterShoes(List<ClothingItem> items) {
    return items.where((it) {
      if (shoeType != null && it.shoeType != shoeType) return false;
      if (shoesColor != null && it.color != shoesColor) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(clothingRepoProvider);

    // Rohdaten
    final allTops = repo.loadByCategory(ClothingCategory.top);
    final allBottoms = repo.loadByCategory(ClothingCategory.bottom);
    final allShoes = repo.loadByCategory(ClothingCategory.shoes);

    // Gefiltert (WICHTIG: das ist die Swipe-Liste!)
    final tops = _filterTops(allTops);
    final bottoms = _filterBottoms(allBottoms);
    final shoes = _filterShoes(allShoes);

    // Index in gefilterten Listen "safe" halten
    topIndex = _wrap(topIndex, tops.length);
    bottomIndex = _wrap(bottomIndex, bottoms.length);
    shoesIndex = _wrap(shoesIndex, shoes.length);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final leftW = (constraints.maxWidth * 0.33).clamp(150.0, 260.0);
          final rightW = constraints.maxWidth - leftW;

          final height = constraints.maxHeight;

          // Bildanteile: 40/45/15
          final topH = height * 0.40;
          final bottomH = height * 0.45;
          final shoesH = height * 0.15;

          // Bauchnabel-Linie (global) -> relativ zum rechten Bereich
          final anchorX = constraints.maxWidth * 0.60;
          final localAnchorX = (anchorX - leftW).clamp(0.0, rightW);

          // Foto-/Silhouette-Zone Breite
          final outfitMaxW = (rightW * 0.8).clamp(220.0, 420.0);

          final alignX = rightW <= 0 ? 0.0 : (localAnchorX / rightW) * 2.0 - 1.0;

          return Row(
            children: [
              // ================= FILTERS (SCROLLABLE) =================
              SizedBox(
                width: leftW,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      _OuterwearBlock(
                        value: showOuterwear,
                        onChanged: null, // bewusst deaktiviert
                      ),
                      const Divider(),

                      _FilterBlock(
                        title: 'Oberteil',
                        type: _typeDropdown<TopType>(
                          value: topType,
                          values: TopType.values,
                          label: topTypeLabel,
                          onChanged: (v) => setState(() {
                            topType = v;
                            topIndex = 0; // wichtig!
                          }),
                        ),
                        color: _colorDropdown(
                          value: topColor,
                          onChanged: (v) => setState(() {
                            topColor = v;
                            topIndex = 0; // wichtig!
                          }),
                        ),
                        hint: 'Treffer: ${tops.length}',
                      ),
                      const Divider(),

                      _FilterBlock(
                        title: 'Unterteil',
                        type: _typeDropdown<BottomType>(
                          value: bottomType,
                          values: BottomType.values,
                          label: bottomTypeLabel,
                          onChanged: (v) => setState(() {
                            bottomType = v;
                            bottomIndex = 0;
                          }),
                        ),
                        color: _colorDropdown(
                          value: bottomColor,
                          onChanged: (v) => setState(() {
                            bottomColor = v;
                            bottomIndex = 0;
                          }),
                        ),
                        hint: 'Treffer: ${bottoms.length}',
                      ),
                      const Divider(),

                      _FilterBlock(
                        title: 'Schuhe',
                        type: _typeDropdown<ShoeType>(
                          value: shoeType,
                          values: ShoeType.values,
                          label: shoeTypeLabel,
                          onChanged: (v) => setState(() {
                            shoeType = v;
                            shoesIndex = 0;
                          }),
                        ),
                        color: _colorDropdown(
                          value: shoesColor,
                          onChanged: (v) => setState(() {
                            shoesColor = v;
                            shoesIndex = 0;
                          }),
                        ),
                        hint: 'Treffer: ${shoes.length}',
                      ),
                    ],
                  ),
                ),
              ),

              // ================= OUTFIT (mit Silhouette im Hintergrund) =================
              SizedBox(
                width: rightW,
                child: Stack(
                  children: [
                    // Silhouette immer sichtbar im Hintergrund,
                    // wenn ein Segment kein Bild hat, sieht man sie.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: 0.12,
                          child: Align(
                            alignment: Alignment(alignX, 0),
                            child: SizedBox(
                              width: outfitMaxW,
                              child: const FittedBox(
                                fit: BoxFit.contain,
                                child: Icon(Icons.woman, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        _SwipeImage(
                          height: topH,
                          item: _current(tops, topIndex),
                          localAnchorX: localAnchorX,
                          rightW: rightW,
                          outfitMaxW: outfitMaxW,
                          onPrev: () => setState(() => topIndex--),
                          onNext: () => setState(() => topIndex++),
                        ),
                        _SwipeImage(
                          height: bottomH,
                          item: _current(bottoms, bottomIndex),
                          localAnchorX: localAnchorX,
                          rightW: rightW,
                          outfitMaxW: outfitMaxW,
                          onPrev: () => setState(() => bottomIndex--),
                          onNext: () => setState(() => bottomIndex++),
                        ),
                        _SwipeImage(
                          height: shoesH,
                          item: _current(shoes, shoesIndex),
                          localAnchorX: localAnchorX,
                          rightW: rightW,
                          outfitMaxW: outfitMaxW,
                          onPrev: () => setState(() => shoesIndex--),
                          onNext: () => setState(() => shoesIndex++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* ================= WIDGETS ================= */

class _SwipeImage extends StatelessWidget {
  const _SwipeImage({
    required this.height,
    required this.item,
    required this.localAnchorX,
    required this.rightW,
    required this.outfitMaxW,
    required this.onPrev,
    required this.onNext,
  });

  final double height;
  final ClothingItem? item;
  final double localAnchorX;
  final double rightW;
  final double outfitMaxW;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final alignX = rightW <= 0 ? 0.0 : (localAnchorX / rightW) * 2.0 - 1.0;

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 0) onPrev();
        if ((d.primaryVelocity ?? 0) < 0) onNext();
      },
      child: SizedBox(
        height: height,
        width: double.infinity,
        // Wenn kein passendes Item existiert => NICHTS anzeigen (Hintergrund bleibt sichtbar)
        child: item == null
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment(alignX, 0),
                child: SizedBox(
                  width: outfitMaxW,
                  child: Image.file(
                    File(item!.normalizedImagePath),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
      ),
    );
  }
}

class _FilterBlock extends StatelessWidget {
  const _FilterBlock({
    required this.title,
    required this.type,
    required this.color,
    this.hint,
  });

  final String title;
  final Widget type;
  final Widget color;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hint != null)
                Text(
                  hint!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 6),
          type,
          const SizedBox(height: 6),
          color,
        ],
      ),
    );
  }
}

class _OuterwearBlock extends StatelessWidget {
  const _OuterwearBlock({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Jacke / Mantel'),
      subtitle: const Text('Kommt später'),
      trailing: Switch(
        value: value,
        onChanged: onChanged, // absichtlich null
      ),
    );
  }
}

/* ================= DROPDOWNS ================= */

Widget _typeDropdown<T>({
  required T? value,
  required List<T> values,
  required String Function(T) label,
  required ValueChanged<T?> onChanged,
}) {
  return DropdownButtonFormField<T>(
    value: value,
    isExpanded: true,
    items: [
      DropdownMenuItem<T>(
        value: null,
        child: const Text('Typ: alle'),
      ),
      ...values.map((t) => DropdownMenuItem(
            value: t,
            child: Text(label(t)),
          )),
    ],
    onChanged: onChanged,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      isDense: true,
    ),
  );
}

Widget _colorDropdown({
  required ColorTag? value,
  required ValueChanged<ColorTag?> onChanged,
}) {
  return DropdownButtonFormField<ColorTag>(
    value: value,
    isExpanded: true,
    items: [
      const DropdownMenuItem(
        value: null,
        child: Text('Farbe: alle'),
      ),
      ...ColorTag.values.map((c) => DropdownMenuItem(
            value: c,
            child: Text(colorLabel(c)),
          )),
    ],
    onChanged: onChanged,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      isDense: true,
    ),
  );
}
