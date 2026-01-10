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
import '../../services/chatgpt_prompt_builder.dart';
import '../../services/outfit_merge_service.dart';

final outfitControllerProvider = Provider<OutfitController>((ref) {
  return OutfitController();
});

class OutfitController {
  Future<void> shareToGemini(
    BuildContext context,
    List<MergeLayerInfo> selectedLayers,
  ) async {
    await shareToChatGPT(context, selectedLayers);
  }

  Future<void> shareToChatGPT(
    BuildContext context,
    List<MergeLayerInfo> selectedLayers,
  ) async {
    final promptText = ChatGptPromptBuilder().buildPrompt(selectedLayers);
    await Clipboard.setData(ClipboardData(text: promptText));
    if (!context.mounted) return;

    final xfiles = await _buildShareXFiles(context, selectedLayers);
    if (xfiles == null || xfiles.isEmpty) return;

    await Share.shareXFiles(
      xfiles,
      text: 'Paste the prompt from clipboard to merge these layers.',
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prompt copied. Paste it in GPT.')),
    );
  }
}

Future<List<XFile>?> _buildShareXFiles(
  BuildContext context,
  List<MergeLayerInfo> layers,
) async {
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
