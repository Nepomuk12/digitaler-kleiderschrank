// Aufgabe: Steuerung fürs Outfit-Sharing (Prompt + Bilder) und Merge-Layer-Mapping.
// Hauptfunktionen: Share zu Gemini/ChatGPT, Erzeugung von XFiles, Layer-Info bauen.
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/clothing_item_hive.dart';
import '../../domain/merge_layer_info.dart';
import '../../domain/tag_labels.dart';
import '../../services/llm_prompt_builder.dart';
import '../../services/contact_sheet_generator.dart';
import '../../services/outfit_merge_service.dart';

final outfitControllerProvider = Provider<OutfitController>((ref) {
  return OutfitController();
});

class OutfitController {
  Future<void> shareToGemini(
    BuildContext context,
    List<MergeLayerInfo> selectedLayers,
  ) async {
    // Derzeit identisch zu ChatGPT-Flow (Prompt + Bilder).
    await shareToChatGPT(context, selectedLayers);
  }

  Future<void> shareToChatGPT(
    BuildContext context,
    List<MergeLayerInfo> selectedLayers,
  ) async {
    // Baut Prompt, kopiert in die Zwischenablage und teilt Bilder via Share.
    final promptText = LlmPromptBuilder().buildPrompt(selectedLayers);
    await Clipboard.setData(ClipboardData(text: promptText));
    if (!context.mounted) return;

    XFile? contactSheetFile;
    try {
      final contactSheetPath = await ContactSheetGenerator().createOutfitContactSheet(
        layers: selectedLayers,
        cellSizePx: 768,
      );
      contactSheetFile = XFile(contactSheetPath);
    } catch (_) {
      contactSheetFile = null;
    }

    if (contactSheetFile != null) {
      await Share.shareXFiles(
        [contactSheetFile],
        text:
            'Prompt copied to clipboard. Paste it into ChatGPT/Gemini and send with this image.',
      );
    } else {
      final xfiles = await _buildShareXFiles(context, selectedLayers);
      if (xfiles == null || xfiles.isEmpty) return;
      await Share.shareXFiles(
        xfiles,
        text:
            'Prompt copied to clipboard. Paste it into ChatGPT/Gemini and send with this image.',
      );
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prompt copied. Paste it into ChatGPT/Gemini.')),
    );
  }
}

Future<List<XFile>?> _buildShareXFiles(
  BuildContext context,
  List<MergeLayerInfo> layers,
) async {
  // Sammelt die Layer-Bilder im Temp-Ordner für das Teilen.
  final tempDir = await getTemporaryDirectory();
  final xfiles = <XFile>[];
  final sortedLayers = [...layers]..sort((a, b) => a.zIndex.compareTo(b.zIndex));

  for (final layer in sortedLayers) {
    final source = File(layer.localImagePath);
    if (!await source.exists()) {
      if (!context.mounted) return null;
      final label = layer.typeLabel.trim().isEmpty ? 'Bild' : layer.typeLabel;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bild fehlt: $label')),
      );
      return null;
    }

    final fileName = 'gemini_${layer.itemId}_${p.basename(layer.localImagePath)}';
    final targetPath = p.join(tempDir.path, fileName);
    await source.copy(targetPath);
    xfiles.add(XFile(targetPath));
  }

  return xfiles;
}

List<MergeLayerInfo> buildMergeLayerInfoFromSelection({
  required ClothingItem? top,
  required ClothingItem? bottom,
  required ClothingItem? shoes,
  required MergeLayer topLayer,
  required MergeLayer bottomLayer,
  required MergeLayer shoesLayer,
  required WearRelation topBottomRelation,
  required WearRelation bottomShoesRelation,
}) {
  // Übersetzt die aktuelle Auswahl in Layer-Infos für Merge/LLM.
  final layers = <MergeLayerInfo>[];

  if (shoes != null) {
    layers.add(
      MergeLayerInfo(
        itemId: shoes.id,
        typeLabel: shoes.shoeType != null ? shoeTypeLabel(shoes.shoeType!) : 'Schuhe',
        slot: LayerSlot.shoes,
        zIndex: shoesLayer.z,
        localImagePath: shoes.normalizedImagePath,
        brandNotes: shoes.brandNotes,
        topBottomRelation: topBottomRelation,
        bottomShoesRelation: bottomShoesRelation,
      ),
    );
  }

  if (bottom != null) {
    layers.add(
      MergeLayerInfo(
        itemId: bottom.id,
        typeLabel:
            bottom.bottomType != null ? bottomTypeLabel(bottom.bottomType!) : 'Hose',
        slot: LayerSlot.bottom,
        zIndex: bottomLayer.z,
        localImagePath: bottom.normalizedImagePath,
        brandNotes: bottom.brandNotes,
        topBottomRelation: topBottomRelation,
        bottomShoesRelation: bottomShoesRelation,
      ),
    );
  }

  if (top != null) {
    layers.add(
      MergeLayerInfo(
        itemId: top.id,
        typeLabel: top.topType != null ? topTypeLabel(top.topType!) : 'Oberteil',
        slot: LayerSlot.top,
        zIndex: topLayer.z,
        localImagePath: top.normalizedImagePath,
        brandNotes: top.brandNotes,
        topBottomRelation: topBottomRelation,
        bottomShoesRelation: bottomShoesRelation,
      ),
    );
  }

  return layers;
}
