// Aufgabe: UI zum Hinzufügen neuer Kleidungsstücke inklusive Foto und Metadaten.
// Hauptfunktionen: Bildauswahl/Preview, Metadaten-Eingabe, Speichern via Controller.
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
  ColorTag? color;
  TopType? topType;
  BottomType? bottomType;
  ShoeType? shoeType;
  List<OutfitOccasion> selectedOccasions = [];

  final _brandCtrl = TextEditingController();

  @override
  void dispose() {
    _brandCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI: Schritt-für-Schritt-Erfassung, abhängig vom Bildstatus.
    final state = ref.watch(addItemControllerProvider);
    final ctrl = ref.read(addItemControllerProvider.notifier);
    final prefillCategory = ref.watch(addItemPrefillCategoryProvider);

    if (prefillCategory != null && prefillCategory != category) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => category = prefillCategory);
        ref.read(addItemPrefillCategoryProvider.notifier).state = null;
      });
    }

    // Release-Date: wird beim Build aus --dart-define gesetzt (siehe Hinweis unten)
    const releaseDate = String.fromEnvironment(
      'RELEASE_DATE',
      defaultValue: 'DEV',
    );

    Widget typeDropdown() {
      // Zeigt den Typ-Dropdown passend zur gewählten Kategorie.
      switch (category) {
        case ClothingCategory.top:
          return DropdownButtonFormField<TopType>(
            value: topType,
            items: TopType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(topTypeLabel(t)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => topType = v),
            decoration: const InputDecoration(labelText: 'Typ'),
          );
        case ClothingCategory.bottom:
          return DropdownButtonFormField<BottomType>(
            value: bottomType,
            items: BottomType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(bottomTypeLabel(t)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => bottomType = v),
            decoration: const InputDecoration(labelText: 'Typ'),
          );
        case ClothingCategory.shoes:
          return DropdownButtonFormField<ShoeType>(
            value: shoeType,
            items: ShoeType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(shoeTypeLabel(t)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => shoeType = v),
            decoration: const InputDecoration(labelText: 'Typ'),
          );
        case ClothingCategory.outerwear:
          return const SizedBox.shrink();
        case ClothingCategory.outfit:
          return const SizedBox.shrink();
      }
    }

    Widget tipText() {
      // Kurze Hinweise für bessere Fotoqualität.
      const style = TextStyle(
        color: Colors.black54,
        fontSize: 13,
        height: 1.25,
      );

      return const Text(
        'Info:\n'
        '1) Fotos aus gleichem Abstand, Winkel sowie ähnlichem Licht & gleicher Körperhaltung\n'
        '2) Hautfarbener Body hilft beim merge\n'
        '3) Zuschneiden in der App mit Fokus auf Kategorie (z.B. Oberbekleidung mit sichtbarer Ärmellänge)\n'
        '4) Dann Outfit im nächsten Tab zusammenstellen',
        textAlign: TextAlign.center,
        style: style,
      );
    }

    Widget footer() {
      // Versions-/Release-Hinweis im Footer.
      return const Text(
        'Version 1.2.3a\n'
        'Release Date: $releaseDate\n'
        'Copyright: C.Bohne',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 12,
          height: 1.2,
        ),
      );
    }

    Future<void> editOccasions() async {
      // Dialog zum Auswählen von Outfit-Anlässen.
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

    return Scaffold(
      appBar: AppBar(title: const Text('Kleidung hinzufügen')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mittige Anleitung (dezent) – nur solange noch kein Bild gewählt wurde
                      if (!state.hasImage) ...[
                        const SizedBox(height: 18),
                        tipText(),
                        const SizedBox(height: 18),
                      ],

                      // 📸 Schritt 1
                      if (!state.hasImage) ...[
                        ElevatedButton.icon(
                          onPressed: () => ctrl.pickImage(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Foto aufnehmen'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => ctrl.pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Aus Galerie wählen'),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Image.asset(
                            'assets/images/foto_manual.png',
                            height: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],

                      // 🖼️ Vorschau + Attribute
                      if (state.hasImage) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(state.normalizedPath!),
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<ClothingCategory>(
                          value: category,
                          items: ClothingCategory.values
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(categoryLabel(c)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() {
                            category = v!;
                            if (category == ClothingCategory.outfit) {
                              color = null;
                              topType = null;
                              bottomType = null;
                              shoeType = null;
                            } else {
                              selectedOccasions = [];
                            }
                          }),
                          decoration: const InputDecoration(labelText: 'Kategorie'),
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
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(colorLabel(c)),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => color = v),
                            decoration: const InputDecoration(labelText: 'Farbe'),
                          )
                        else ...[
                          OutlinedButton(
                            onPressed: editOccasions,
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

                        typeDropdown(),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _brandCtrl,
                          decoration: const InputDecoration(labelText: 'Marke / Notizen'),
                        ),

                        const SizedBox(height: 20),

                        FilledButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Speichern'),
                          onPressed: () async {
                            await ctrl.saveItem(
                              category: category,
                              color: color,
                              topType: topType,
                              bottomType: bottomType,
                              shoeType: shoeType,
                              occasions: selectedOccasions,
                              brandNotes: _brandCtrl.text.trim().isEmpty
                                  ? null
                                  : _brandCtrl.text.trim(),
                            );
                            _brandCtrl.clear();
                          },
                        ),
                      ],

                      if (state.loading) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ],

                      const Spacer(),

                      // Footer unten, klein & grau
                      footer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
