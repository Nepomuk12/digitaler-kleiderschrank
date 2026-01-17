// Aufgabe: Outfit-Zusammenstellung mit Filtern, Swipe-Auswahl und Merge-UI.
// Hauptfunktionen: Filterlogik, Auswahl-UI, Merge-Ausführung und Ergebnisanzeige.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/clothing_item_hive.dart';
import '../../domain/merge_layer_info.dart';
import '../../domain/tag_labels.dart';
import '../../app_state.dart';
import '../add_item/add_item_controller.dart';
import '../../services/outfit_merge_service.dart';
import 'outfit_controller.dart';

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

  // Merge menu (unten im Scroll)
  MergeLayer topLayer = MergeLayer.top; // Top Layer = T-Shirt über Hose
  MergeLayer bottomLayer = MergeLayer.middle; // Middle Layer = Hosenbund verdeckt
  MergeLayer shoesLayer = MergeLayer.bottom; // Bottom Layer = Stiefelschaft verdeckt

  final OutfitMergeService _mergeService = const OutfitMergeService();

  int _wrap(int i, int len) {
    // Hält Indizes zyklisch im Bereich der Liste.
    if (len <= 0) return 0;
    final r = i % len;
    return r < 0 ? r + len : r;
  }

  ClothingItem? _current(List<ClothingItem> list, int i) =>
      list.isEmpty ? null : list[_wrap(i, list.length)];

  /* ================= FILTER LOGIC ================= */

  List<ClothingItem> _filterTops(List<ClothingItem> items) {
    // Filtert Oberteile anhand des aktuellen Typ-/Farbfilters.
    return items.where((it) {
      if (topType != null && it.topType != topType) return false;
      if (topColor != null && it.color != topColor) return false;
      return true;
    }).toList();
  }

  List<ClothingItem> _filterBottoms(List<ClothingItem> items) {
    // Filtert Unterteile anhand des aktuellen Typ-/Farbfilters.
    return items.where((it) {
      if (bottomType != null && it.bottomType != bottomType) return false;
      if (bottomColor != null && it.color != bottomColor) return false;
      return true;
    }).toList();
  }

  List<ClothingItem> _filterShoes(List<ClothingItem> items) {
    // Filtert Schuhe anhand des aktuellen Typ-/Farbfilters.
    return items.where((it) {
      if (shoeType != null && it.shoeType != shoeType) return false;
      if (shoesColor != null && it.color != shoesColor) return false;
      return true;
    }).toList();
  }

  /// Liefert verfügbare Werte (nur die, die tatsächlich vorkommen), optional mit
  /// zusätzlichem Prädikat (z.B. "nur Farben, die zum ausgewählten Typ passen")
  List<T> _availableTypes<T>(
    List<ClothingItem> items,
    T? Function(ClothingItem) pick,
    bool Function(ClothingItem) where,
    String Function(T) label,
  ) {
    // Baut verfügbare Typen aus den Items und sortiert sie nach Label.
    final set = <T>{};
    for (final it in items) {
      if (!where(it)) continue;
      final v = pick(it);
      if (v != null) set.add(v);
    }
    final list = set.toList();
    list.sort((a, b) => label(a).compareTo(label(b)));
    return list;
  }

  List<ColorTag> _availableColors(
    List<ClothingItem> items,
    bool Function(ClothingItem) where,
  ) {
    // Baut verfügbare Farben aus den Items und sortiert sie.
    final set = <ColorTag>{};
    for (final it in items) {
      if (!where(it)) continue;
      if (it.color != null) set.add(it.color!);
    }
    final list = set.toList();
    list.sort((a, b) => colorLabel(a).compareTo(colorLabel(b)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // UI: linke Filterspalte, rechte Outfit-Vorschau mit Swipe-Auswahl.
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

    /* ====== FILTERED LISTS ====== */

    final tops = _filterTops(allTops);
    final bottoms = _filterBottoms(allBottoms);
    final shoes = _filterShoes(allShoes);

    /* ====== Index clamps (falls Auswahl reduziert wurde) ====== */
    topIndex = _wrap(topIndex, tops.length);
    bottomIndex = _wrap(bottomIndex, bottoms.length);
    shoesIndex = _wrap(shoesIndex, shoes.length);

    final selectedTop = _current(tops, topIndex);
    final selectedBottom = _current(bottoms, bottomIndex);
    final selectedShoes = _current(shoes, shoesIndex);
    const topBottomRelation = WearRelation.over;
    const bottomShoesRelation = WearRelation.over;
    final selectedLayers = buildMergeLayerInfoFromSelection(
      top: selectedTop,
      bottom: selectedBottom,
      shoes: selectedShoes,
      topLayer: topLayer,
      bottomLayer: bottomLayer,
      shoesLayer: shoesLayer,
      topBottomRelation: topBottomRelation,
      bottomShoesRelation: bottomShoesRelation,
    );
    final canShareToGemini = selectedLayers.length == 3;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Layout wie zuvor (oberer Teil wieder wie "perfekt")
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
              /* ================= FILTER COLUMN ================= */
              SizedBox(
                width: leftW,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      _OuterwearBlock(
                        value: showOuterwear,
                        onChanged: null, // vorbereitet, aber (noch) deaktiviert
                      ),
                      const Divider(),

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

                      // NEU: unten im Scroll die Layer-Dropdowns + Merge Button (kompakt)
                      const Divider(),
                      _MergeBlock(
                        topLayer: topLayer,
                        bottomLayer: bottomLayer,
                        shoesLayer: shoesLayer,
                        onTopChanged: (v) => setState(() => topLayer = v),
                        onBottomChanged: (v) => setState(() => bottomLayer = v),
                        onShoesChanged: (v) => setState(() => shoesLayer = v),
                        onMerge: () => _handleMerge(tops, bottoms, shoes),
                        canShareToGemini: canShareToGemini,
                        onShareToGemini: () => ref
                            .read(outfitControllerProvider)
                            .shareToGemini(context, selectedLayers),
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

  Future<void> _handleMerge(
    List<ClothingItem> tops,
    List<ClothingItem> bottoms,
    List<ClothingItem> shoes,
  ) async {
    // Führt den Merge durch, zeigt Loading-Dialog und Ergebnis-Popup.
    final top = _current(tops, topIndex);
    final bottom = _current(bottoms, bottomIndex);
    final shoesIt = _current(shoes, shoesIndex);
    if (top == null || bottom == null || shoesIt == null) return;

    // Loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      final mergedPath = await _mergeService.mergeToTempPng(
        top: MergeInput(normalizedImagePath: top.normalizedImagePath, categoryOrder: 0),
        bottom: MergeInput(normalizedImagePath: bottom.normalizedImagePath, categoryOrder: 1),
        shoes: MergeInput(normalizedImagePath: shoesIt.normalizedImagePath, categoryOrder: 2),
        topLayer: topLayer,
        bottomLayer: bottomLayer,
        shoesLayer: shoesLayer,
      );

      if (!mounted) return;
      Navigator.pop(context); // close loading

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Merged Outfit'),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(mergedPath),
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _addMergedToWardrobe(mergedPath);
              },
              child: const Text('Outfit speichern'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Schließen'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merge fehlgeschlagen')),
      );
    }
  }

  Future<void> _addMergedToWardrobe(String mergedPath) async {
    try {
      await ref.read(addItemControllerProvider.notifier).importMergedImage(mergedPath);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merge-Bild konnte nicht importiert werden')),
      );
      return;
    }
    if (!mounted) return;
    ref.read(addItemPrefillCategoryProvider.notifier).state = ClothingCategory.outfit;
    ref.read(tabIndexProvider.notifier).state = 0;
  }

  Widget _typeDropdown<T>({
    required T? value,
    required List<T> values,
    required String Function(T) label,
    required ValueChanged<T?> onChanged,
  }) {
    // Generische Typ-Auswahl für Filter.
    return DropdownButtonFormField<T?>(
      value: value,
      isExpanded: true,
      items: [
        DropdownMenuItem<T?>(
          value: null,
          child: const Text('Typ: alle'),
        ),
        ...values.map((t) => DropdownMenuItem<T?>(
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
    // Farb-Auswahl für Filter.
    return DropdownButtonFormField<ColorTag?>(
      value: value,
      isExpanded: true,
      items: [
        const DropdownMenuItem<ColorTag?>(
          value: null,
          child: Text('Farbe: alle'),
        ),
        ...values.map((c) => DropdownMenuItem<ColorTag?>(
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
}

/* ================= MERGE UI (kompakt) ================= */

// ===== Replace your current _MergeBlock with this version =====

String _layerLabel(MergeLayer l) {
  // Label für das Dropdown der Layer-Reihenfolge.
  switch (l) {
    case MergeLayer.top:
      return 'TopLayer';
    case MergeLayer.middle:
      return 'MiddleLayer';
    case MergeLayer.bottom:
      return 'BottomLayer';
  }
}

class _MergeBlock extends StatelessWidget {
  const _MergeBlock({
    required this.topLayer,
    required this.bottomLayer,
    required this.shoesLayer,
    required this.onTopChanged,
    required this.onBottomChanged,
    required this.onShoesChanged,
    required this.onMerge,
    required this.canShareToGemini,
    required this.onShareToGemini,
  });

  final MergeLayer topLayer;
  final MergeLayer bottomLayer;
  final MergeLayer shoesLayer;

  final ValueChanged<MergeLayer> onTopChanged;
  final ValueChanged<MergeLayer> onBottomChanged;
  final ValueChanged<MergeLayer> onShoesChanged;

  final VoidCallback onMerge;
  final bool canShareToGemini;
  final VoidCallback onShareToGemini;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // Design analog zu den Filterblöcken: 1 Dropdown je Kategorie
          _mergeDropdown(
            title: 'Oberteil',
            value: topLayer,
            onChanged: onTopChanged,
          ),
          const SizedBox(height: 8),
          _mergeDropdown(
            title: 'Unterteil',
            value: bottomLayer,
            onChanged: onBottomChanged,
          ),
          const SizedBox(height: 8),
          _mergeDropdown(
            title: 'Schuhe',
            value: shoesLayer,
            onChanged: onShoesChanged,
          ),

          const SizedBox(height: 7),
          Column(
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMerge,
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Merge'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canShareToGemini ? onShareToGemini : null,
                        icon: const Icon(Icons.share),
                        label: const Text('Gemini'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mergeDropdown({
    required String title,
    required MergeLayer value,
    required ValueChanged<MergeLayer> onChanged,
  }) {
    // Dropdown für die Layer-Zuordnung einer Kategorie.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        DropdownButtonFormField<MergeLayer>(
          value: value,
          isExpanded: true,
          items: MergeLayer.values
              .map(
                (l) => DropdownMenuItem(
                  value: l,
                  child: Text(_layerLabel(l)),
                ),
              )
              .toList(),
          onChanged: (v) => v == null ? null : onChanged(v),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
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
                  height: height,
                  child: Image.file(
                    File(item!.normalizedImagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
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
      // subtitle: const Text('Kommt später'),
      trailing: Switch(
        value: value,
        onChanged: onChanged, // bewusst deaktiviert
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          type,
          const SizedBox(height: 8),
          color,
        ],
      ),
    );
  }
}
