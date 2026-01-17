// Aufgabe: Kleiderschrank-Übersicht mit Grid, Filtern und Item-Bearbeitung.
// Hauptfunktionen: Filterlogik, Grid-Rendering, Bearbeiten/Löschen von Items.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as p;

import '../../data/clothing_repository.dart';
import '../../domain/clothing_item_hive.dart';
import '../../domain/tag_labels.dart';
import '../../services/image_normalizer.dart';
import '../add_item/add_item_controller.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  ClothingCategory? filterCategory; // null = alle
  String? filterPick; // null = alle, sonst "type:..." oder "color:..."

  T? _safeDropdownValue<T>(T? current, Set<T> available) {
    if (current == null) return null;
    return available.contains(current) ? current : null;
  }

  // Prüft, ob ein Item den aktiven Kategorie-/Untergruppenfilter erfüllt.
  bool _matchesFilters(ClothingItem it) {
    if (filterCategory != null && it.category != filterCategory) return false;

    if (filterPick == null) return true;

    if (filterPick!.startsWith('type:')) {
      final typeName = filterPick!.substring('type:'.length);

      switch (it.category) {
        case ClothingCategory.top:
          return it.topType?.name == typeName;
        case ClothingCategory.bottom:
          return it.bottomType?.name == typeName;
        case ClothingCategory.shoes:
          return it.shoeType?.name == typeName;
        case ClothingCategory.outerwear:
          // aktuell kein outerwearType -> daher "type:" ignorieren (kein Match)
          return false;
        case ClothingCategory.outfit:
          return it.occasions.any((o) => o.name == typeName);
      }
    }

    if (filterPick!.startsWith('color:')) {
      final colorName = filterPick!.substring('color:'.length);
      return it.color?.name == colorName;
    }

    return true;
  }

  List<DropdownMenuItem<String>> _buildFilterPickItems(
    List<ClothingItem> allItems,
    ClothingCategory? cat,
    BuildContext context,
  ) {
    // Baut dynamische Dropdown-Optionen aus den vorhandenen Items.
    // nur Items der Kategorie (oder alle, wenn null)
    final base = cat == null ? allItems : allItems.where((e) => e.category == cat).toList();

    final typeValues = <String>{};
    final colorValues = <String>{};

    for (final it in base) {
      if (it.color != null) colorValues.add(it.color!.name);

      if (cat == null) {
        // Wenn "alle Kategorien": Typ-Filter wäre uneindeutig -> nicht anbieten
        continue;
      }

      switch (cat) {
        case ClothingCategory.top:
          if (it.topType != null) typeValues.add(it.topType!.name);
          break;
        case ClothingCategory.bottom:
          if (it.bottomType != null) typeValues.add(it.bottomType!.name);
          break;
        case ClothingCategory.shoes:
          if (it.shoeType != null) typeValues.add(it.shoeType!.name);
          break;
        case ClothingCategory.outerwear:
          // noch kein outerwearType
          break;
        case ClothingCategory.outfit:
          if (it.occasions.isNotEmpty) {
            for (final o in it.occasions) {
              typeValues.add(o.name);
            }
          }
          break;
      }
    }

    String typeLabelFromName(String name) {
      if (cat == null) return name;
      switch (cat) {
        case ClothingCategory.top:
          return topTypeLabel(TopType.values.firstWhere((e) => e.name == name));
        case ClothingCategory.bottom:
          return bottomTypeLabel(BottomType.values.firstWhere((e) => e.name == name));
        case ClothingCategory.shoes:
          return shoeTypeLabel(ShoeType.values.firstWhere((e) => e.name == name));
        case ClothingCategory.outerwear:
          return name;
        case ClothingCategory.outfit:
          return outfitOccasionLabel(OutfitOccasion.values.firstWhere((e) => e.name == name));
      }
    }

    String colorLabelFromName(String name) {
      return colorLabel(ColorTag.values.firstWhere((e) => e.name == name));
    }

    final sortedTypes = typeValues.toList()..sort((a, b) => typeLabelFromName(a).compareTo(typeLabelFromName(b)));
    final sortedColors = colorValues.toList()..sort((a, b) => colorLabelFromName(a).compareTo(colorLabelFromName(b)));

    final items = <DropdownMenuItem<String>>[];

    items.add(const DropdownMenuItem<String>(
      value: null,
      child: Text('Untergruppe: alle'),
    ));

    // Typen nur anbieten, wenn genau eine Kategorie gewählt ist und Typen existieren
    if (cat != null && sortedTypes.isNotEmpty) {
      for (final t in sortedTypes) {
        items.add(
          DropdownMenuItem<String>(
            value: 'type:$t',
            child: Text('Typ: ${typeLabelFromName(t)}'),
          ),
        );
      }
    }

    if (sortedColors.isNotEmpty) {
      for (final c in sortedColors) {
        items.add(
          DropdownMenuItem<String>(
            value: 'color:$c',
            child: Text('Farbe: ${colorLabelFromName(c)}'),
          ),
        );
      }
    }

    return items;
  }

  // Speichert ein Item als aktuelle Outfit-Auswahl und bereinigt widersprechende Filter.
  Future<void> _useInCurrentOutfit(ClothingItem it) async {
    final stateBox = Hive.box('outfit_state');

    switch (it.category) {
      case ClothingCategory.top:
        stateBox.put('topId', it.id);
        if (stateBox.get('topType') != null && it.topType?.name != stateBox.get('topType')) {
          stateBox.put('topType', null);
        }
        if (stateBox.get('topColor') != null && it.color?.name != stateBox.get('topColor')) {
          stateBox.put('topColor', null);
        }
        break;
      case ClothingCategory.bottom:
        stateBox.put('bottomId', it.id);
        if (stateBox.get('bottomType') != null &&
            it.bottomType?.name != stateBox.get('bottomType')) {
          stateBox.put('bottomType', null);
        }
        if (stateBox.get('bottomColor') != null && it.color?.name != stateBox.get('bottomColor')) {
          stateBox.put('bottomColor', null);
        }
        break;
      case ClothingCategory.shoes:
        stateBox.put('shoesId', it.id);
        if (stateBox.get('shoeType') != null && it.shoeType?.name != stateBox.get('shoeType')) {
          stateBox.put('shoeType', null);
        }
        if (stateBox.get('shoesColor') != null && it.color?.name != stateBox.get('shoesColor')) {
          stateBox.put('shoesColor', null);
        }
        break;
      case ClothingCategory.outerwear:
        // aktuell kein Outfit-Slot fuer Outerwear
        break;
      case ClothingCategory.outfit:
        // gespeicherte Outfits werden hier nicht in Slots gemappt
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI: Grid mit Items + Filterleiste, Daten kommen aus Hive/Repository.
    final box = Hive.box<ClothingItem>('clothing_items');

    return SafeArea(
      child: Column(
        children: [
          // GRID (oben)
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<ClothingItem> b, _) {
                final all = b.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                final filtered = all.where(_matchesFilters).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final it = filtered[i];

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
                            title: const Text('Im aktuellen Outfit nutzen?'),
                            content: const Text(
                              'Soll dieses Element im aktuellen Outfit angezeigt werden?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Abbrechen'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Ja'),
                              ),
                            ],
                          ),
                        );

                        if (ok == true) {
                          await _useInCurrentOutfit(it);
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
          ),

          // FILTER BAR (unten, direkt über Tab-Bar)
          ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<ClothingItem> b, _) {
              final all = b.values.toList();

              final categoryItems = <DropdownMenuItem<ClothingCategory?>>[
                const DropdownMenuItem<ClothingCategory?>(
                  value: null,
                  child: Text('Bekleidung: alle'),
                ),
                ...ClothingCategory.values.map(
                  (c) => DropdownMenuItem<ClothingCategory?>(
                    value: c,
                    child: Text(categoryLabel(c)),
                  ),
                ),
              ];

              final pickItems = _buildFilterPickItems(all, filterCategory, context);
              final pickAvailable = pickItems
                  .map((e) => e.value)
                  .whereType<String>()
                  .toSet();
              final safePick = _safeDropdownValue(filterPick, pickAvailable);
              if (safePick != filterPick) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => filterPick = safePick);
                });
              }

              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    // Kategorie
                    Expanded(
                      child: DropdownButtonFormField<ClothingCategory?>(
                        value: filterCategory,
                        isExpanded: true,
                        items: categoryItems,
                        onChanged: (v) {
                          setState(() {
                            filterCategory = v;
                            // bei Kategorie-Wechsel Untergruppe/Farbe zurücksetzen,
                            // damit nicht "type:" von vorheriger Kategorie hängen bleibt
                            filterPick = null;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Untergruppe/Farbe (kombiniert)
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: safePick,
                        isExpanded: true,
                        items: pickItems,
                        onChanged: (v) => setState(() => filterPick = v),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    IconButton(
                      tooltip: 'Filter zurücksetzen',
                      onPressed: () => setState(() {
                        filterCategory = null;
                        filterPick = null;
                      }),
                      icon: const Icon(Icons.filter_alt_off),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
  List<OutfitOccasion> selectedOccasions = [];
  final _brandCtrl = TextEditingController();
  bool _recropBusy = false;
  late String _currentNormalizedPath;
  int _recropVersion = 0;

  @override
  void initState() {
    super.initState();
    category = widget.item.category;
    color = widget.item.color;
    topType = widget.item.topType;
    bottomType = widget.item.bottomType;
    shoeType = widget.item.shoeType;
    selectedOccasions = List<OutfitOccasion>.from(widget.item.occasions);
    _brandCtrl.text = widget.item.brandNotes ?? '';
    _currentNormalizedPath = widget.item.normalizedImagePath;
  }

  @override
  void dispose() {
    _brandCtrl.dispose();
    super.dispose();
  }

  Future<void> _reCropFromOriginal(ClothingRepository repo) async {
    if (_recropBusy) return;
    final rawPath = widget.item.rawImagePath;
    if (rawPath == null || rawPath.isEmpty || !File(rawPath).existsSync()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Originalfoto nicht vorhanden.')),
      );
      return;
    }
    final rawPathValue = rawPath;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Item neu zuschneiden?'),
        content: const Text(
          'Möchtest du dieses Item neu zuschneiden? Das Originalfoto wird verwendet und das zugeschnittene Bild wird ersetzt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ja'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _recropBusy = true);
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: rawPathValue,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Zuschneiden',
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
        ],
      );

      if (cropped == null) return;

      final normalizedPath = widget.item.normalizedImagePath;
      final normPath = normalizedPath.isNotEmpty
          ? normalizedPath
          : p.join(p.dirname(rawPathValue), '${widget.item.id}_norm.jpg');

      await ImageNormalizer.resizeToMaxPixels(
        input: File(cropped.path),
        output: File(normPath),
        maxPixels: 2000000,
        jpegQuality: 85,
      );

      // Cache des alten Bildes loeschen, damit die neue Datei angezeigt wird.
      await PaintingBinding.instance.imageCache
          .evict(FileImage(File(normPath)));

      final updated = ClothingItem(
        id: widget.item.id,
        category: widget.item.category,
        imagePath: normPath,
        rawImagePath: rawPathValue,
        normalizedImagePath: normPath,
        createdAt: widget.item.createdAt,
        tags: widget.item.tags,
        color: widget.item.color,
        topType: widget.item.topType,
        bottomType: widget.item.bottomType,
        shoeType: widget.item.shoeType,
        occasions: widget.item.occasions,
        brandNotes: widget.item.brandNotes,
      );

      await repo.upsertItem(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zuschneiden abgeschlossen')),
      );
      setState(() {
        _currentNormalizedPath = normPath;
        _recropVersion++;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Zuschneiden: $e')),
      );
    } finally {
      if (mounted) setState(() => _recropBusy = false);
    }
  }

  Widget _typeDropdown() {
    // Zeigt die passende Typ-Auswahl je Kategorie.
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
      case ClothingCategory.outfit:
        return const SizedBox.shrink();
    }
  }

  void _clearTypesForCategory() {
    // Setzt Typ-Filter zurück, wenn die Kategorie wechselt.
    topType = null;
    bottomType = null;
    shoeType = null;
  }

  Future<void> _editOccasions() async {
    // Dialog zum Bearbeiten der Outfit-Anlässe.
    final temp = List<OutfitOccasion>.from(selectedOccasions);
    final result = await showDialog<List<OutfitOccasion>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Anlässe auswählen'),
              content: SizedBox(
                width: double.maxFinite,
                height: 360,
                child: Scrollbar(
                  child: ListView(
                    children: OutfitOccasion.values.map((o) {
                      final checked = temp.contains(o);
                      return CheckboxListTile(
                        value: checked,
                        title: Text(outfitOccasionLabel(o)),
                        onChanged: (v) {
                          setStateDialog(() {
                            if (v == true) {
                              temp.add(o);
                            } else {
                              temp.remove(o);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () => setStateDialog(() => temp.clear()),
                  child: const Text('Alles löschen'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, temp),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => selectedOccasions = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI: Edit-Sheet mit Foto, Metadaten und Speichern/Löschen.
    final repo = ref.read(clothingRepoProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1) FOTO GROSS (neu)
            GestureDetector(
              onLongPress: _recropBusy ? null : () => _reCropFromOriginal(repo),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.file(
                    File(_currentNormalizedPath),
                    key: ValueKey(_recropVersion),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            if (_recropBusy) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 12),

            // Kategorie
            DropdownButtonFormField<ClothingCategory>(
              value: category,
              items: ClothingCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(categoryLabel(c))))
                  .toList(),
              onChanged: (v) => setState(() {
                category = v ?? category;
                _clearTypesForCategory();
                if (category == ClothingCategory.outfit) {
                  color = null;
                } else {
                  selectedOccasions = [];
                }
              }),
              decoration: const InputDecoration(
                labelText: 'Kategorie',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Farbe/Anlass',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (category != ClothingCategory.outfit)
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
              )
            else ...[
              OutlinedButton(
                onPressed: _editOccasions,
                child: const Text('Anlässe auswählen'),
              ),
              const SizedBox(height: 8),
              Text(
                selectedOccasions.isEmpty
                    ? 'Keine Anlässe ausgewählt'
                    : selectedOccasions.map(outfitOccasionLabel).join(', '),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
            const SizedBox(height: 12),

            // Typ
            _typeDropdown(),
            const SizedBox(height: 12),

            TextField(
              controller: _brandCtrl,
              decoration: const InputDecoration(labelText: 'Marke / Notizen'),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Loeschen'),
                    onPressed: _recropBusy
                        ? null
                        : () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Loeschen?'),
                                content: const Text('Item und Foto werden geloescht.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Abbrechen'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Loeschen'),
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
                    onPressed: _recropBusy
                        ? null
                        : () async {
                            final isOutfit = category == ClothingCategory.outfit;
                            final updated = ClothingItem(
                              id: widget.item.id,
                              category: category,

                              // ?bergang
                              imagePath: _currentNormalizedPath,

                              // Pflichtfelder korrekt weiterreichen
                              rawImagePath: widget.item.rawImagePath,
                              normalizedImagePath: _currentNormalizedPath,

                              createdAt: widget.item.createdAt,
                              tags: widget.item.tags,
                              color: isOutfit ? null : color,
                              topType: topType,
                              bottomType: bottomType,
                              shoeType: shoeType,
                              occasions: isOutfit ? selectedOccasions : const [],
                              brandNotes: _brandCtrl.text.trim().isEmpty
                                  ? null
                                  : _brandCtrl.text.trim(),

                              // Brand/Notes falls vorhanden im Model:
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
      ),
    );
  }
}
