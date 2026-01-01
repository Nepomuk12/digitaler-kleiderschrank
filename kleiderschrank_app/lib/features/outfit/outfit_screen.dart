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

  bool showOuterwear = false;

  int _wrap(int i, int len) {
    if (len <= 0) return 0;
    final r = i % len;
    return r < 0 ? r + len : r;
  }

  ClothingItem? _current(List<ClothingItem> list, int index) =>
      list.isEmpty ? null : list[index];

  /* ================= FILTER LOGIC ================= */

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

  /* ================= AVAILABLE OPTIONS ================= */

  List<T> _availableTypes<T>(
    List<ClothingItem> items,
    T? Function(ClothingItem) extractor,
    bool Function(ClothingItem) matchesOtherFilter,
    String Function(T) label,
  ) {
    final set = items
        .where(matchesOtherFilter)
        .map(extractor)
        .whereType<T>()
        .toSet()
        .toList();

    set.sort((a, b) => label(a).compareTo(label(b)));
    return set;
  }

  List<ColorTag> _availableColors(
    List<ClothingItem> items,
    bool Function(ClothingItem) matchesOtherFilter,
  ) {
    final set = items
        .where(matchesOtherFilter)
        .map((e) => e.color)
        .whereType<ColorTag>()
        .toSet()
        .toList();

    set.sort((a, b) => colorLabel(a).compareTo(colorLabel(b)));
    return set;
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(clothingRepoProvider);

    // Rohdaten
    final allTops = repo.loadByCategory(ClothingCategory.top);
    final allBottoms = repo.loadByCategory(ClothingCategory.bottom);
    final allShoes = repo.loadByCategory(ClothingCategory.shoes);

    /* ====== DROPDOWN-OPTIONEN (WECHSELSEITIG) ====== */

    final availableTopTypes = _availableTypes<TopType>(
      allTops,
      (e) => e.topType,
      (e) => topColor == null || e.color == topColor,
      topTypeLabel,
    );
    final availableTopColors = _availableColors(
      allTops,
      (e) => topType == null || e.topType == topType,
    );

    final availableBottomTypes = _availableTypes<BottomType>(
      allBottoms,
      (e) => e.bottomType,
      (e) => bottomColor == null || e.color == bottomColor,
      bottomTypeLabel,
    );
    final availableBottomColors = _availableColors(
      allBottoms,
      (e) => bottomType == null || e.bottomType == bottomType,
    );

    final availableShoeTypes = _availableTypes<ShoeType>(
      allShoes,
      (e) => e.shoeType,
      (e) => shoesColor == null || e.color == shoesColor,
      shoeTypeLabel,
    );
    final availableShoeColors = _availableColors(
      allShoes,
      (e) => shoeType == null || e.shoeType == shoeType,
    );

    /* ====== SWIPE LISTEN ====== */

    final tops = _filterTops(allTops);
    final bottoms = _filterBottoms(allBottoms);
    final shoes = _filterShoes(allShoes);

    topIndex = _wrap(topIndex, tops.length);
    bottomIndex = _wrap(bottomIndex, bottoms.length);
    shoesIndex = _wrap(shoesIndex, shoes.length);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final leftW = (constraints.maxWidth * 0.33).clamp(150.0, 260.0);
          final rightW = constraints.maxWidth - leftW;

          final height = constraints.maxHeight;
          final topH = height * 0.40;
          final bottomH = height * 0.45;
          final shoesH = height * 0.15;

          final anchorX = constraints.maxWidth * 0.60;
          final localAnchorX = (anchorX - leftW).clamp(0.0, rightW);
          final outfitMaxW = (rightW * 0.8).clamp(220.0, 420.0);
          final alignX =
              rightW <= 0 ? 0.0 : (localAnchorX / rightW) * 2.0 - 1.0;

          return Row(
            children: [
              /* ================= FILTERS ================= */
              SizedBox(
                width: leftW,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      _FilterBlock(
                        title: 'Oberteil',
                        type: _typeDropdown<TopType>(
                          value: topType,
                          values: availableTopTypes,
                          label: topTypeLabel,
                          onChanged: (v) => setState(() {
                            topType = v;
                            topIndex = 0;
                          }),
                        ),
                        color: _colorDropdown(
                          value: topColor,
                          values: availableTopColors,
                          onChanged: (v) => setState(() {
                            topColor = v;
                            topIndex = 0;
                          }),
                        ),
                      ),
                      const Divider(),
                      _FilterBlock(
                        title: 'Unterteil',
                        type: _typeDropdown<BottomType>(
                          value: bottomType,
                          values: availableBottomTypes,
                          label: bottomTypeLabel,
                          onChanged: (v) => setState(() {
                            bottomType = v;
                            bottomIndex = 0;
                          }),
                        ),
                        color: _colorDropdown(
                          value: bottomColor,
                          values: availableBottomColors,
                          onChanged: (v) => setState(() {
                            bottomColor = v;
                            bottomIndex = 0;
                          }),
                        ),
                      ),
                      const Divider(),
                      _FilterBlock(
                        title: 'Schuhe',
                        type: _typeDropdown<ShoeType>(
                          value: shoeType,
                          values: availableShoeTypes,
                          label: shoeTypeLabel,
                          onChanged: (v) => setState(() {
                            shoeType = v;
                            shoesIndex = 0;
                          }),
                        ),
                        color: _colorDropdown(
                          value: shoesColor,
                          values: availableShoeColors,
                          onChanged: (v) => setState(() {
                            shoesColor = v;
                            shoesIndex = 0;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /* ================= OUTFIT ================= */
              SizedBox(
                width: rightW,
                child: Stack(
                  children: [
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
                                child: Icon(Icons.woman),
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
                          alignX: alignX,
                          outfitMaxW: outfitMaxW,
                          onPrev: () => setState(() => topIndex--),
                          onNext: () => setState(() => topIndex++),
                        ),
                        _SwipeImage(
                          height: bottomH,
                          item: _current(bottoms, bottomIndex),
                          alignX: alignX,
                          outfitMaxW: outfitMaxW,
                          onPrev: () => setState(() => bottomIndex--),
                          onNext: () => setState(() => bottomIndex++),
                        ),
                        _SwipeImage(
                          height: shoesH,
                          item: _current(shoes, shoesIndex),
                          alignX: alignX,
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
    required this.alignX,
    required this.outfitMaxW,
    required this.onPrev,
    required this.onNext,
  });

  final double height;
  final ClothingItem? item;
  final double alignX;
  final double outfitMaxW;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 0) onPrev();
        if ((d.primaryVelocity ?? 0) < 0) onNext();
      },
      child: SizedBox(
        height: height,
        width: double.infinity,
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
  });

  final String title;
  final Widget type;
  final Widget color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 6),
          type,
          const SizedBox(height: 6),
          color,
        ],
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
  required List<ColorTag> values,
  required ValueChanged<ColorTag?> onChanged,
}) {
  return DropdownButtonFormField<ColorTag>(
    value: value,
    isExpanded: true,
    items: [
      const DropdownMenuItem<ColorTag>(
        value: null,
        child: Text('Farbe: alle'),
      ),
      ...values.map((c) => DropdownMenuItem(
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
