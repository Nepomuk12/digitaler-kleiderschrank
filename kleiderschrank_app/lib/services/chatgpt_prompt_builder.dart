import '../domain/merge_layer_info.dart';

class ChatGptPromptBuilder {
  String buildPrompt(List<MergeLayerInfo> layers) {
    final top = _findLayer(layers, LayerSlot.top);
    final bottom = _findLayer(layers, LayerSlot.bottom);
    final shoes = _findLayer(layers, LayerSlot.shoes);
    final outerwear = _findLayer(layers, LayerSlot.outerwear);

    final topBottomRelation =
        layers.isEmpty ? 'over' : layers.first.topBottomRelation.name;
    final bottomShoesRelation =
        layers.isEmpty ? 'over' : layers.first.bottomShoesRelation.name;

    return [
      'TASK',
      'Create ONE photorealistic full-body outfit image by COMPOSITING ONLY the garments shown in the provided CONTACT SHEET image. Do NOT invent, redraw, recolor, relight, enhance, or stylize.',
      '',
      'INPUT: CONTACT SHEET (2x2 grid)',
      '- Top-left cell: TOP garment',
      '- Top-right cell: OUTERWEAR garment (optional). If empty/placeholder, ignore.',
      '- Bottom-left cell: BOTTOM garment',
      '- Bottom-right cell: SHOES garment',
      '',
      'REQUIREMENTS (VERY IMPORTANT)',
      '- Preserve ORIGINAL COLORS, texture, seams, logos, and shading of each garment exactly.',
      '- NO color correction, NO relighting, NO contrast boost, NO enhancement, NO style transfer.',
      '- Do NOT add extra body parts (arms/torso/underwear). Do not hallucinate new clothing.',
      '- Output framing: include FULL shoes and add visible floor below shoes (at least 8% image height). Never crop bottom at feet.',
      '- Crop ONLY at the top: start at NOSE (nose visible, eyes/forehead/hair NOT visible). Neutral background.',
      '',
      'LAYER / OCCLUSION RULES',
      '- Use zIndex values only as occlusion priority (higher z covers lower z).',
      '- Explicit relations:',
      '  - top_vs_bottom: $topBottomRelation',
      '  - bottom_vs_shoes: $bottomShoesRelation',
      '  - outerwear_vs_top: over',
      '  - outerwear_vs_bottom: over',
      '',
      'SLOTS',
      _formatSlotLine('TOP', top),
      _formatSlotLine('BOTTOM', bottom),
      _formatSlotLine('SHOES', shoes),
      _formatSlotLine('OUTERWEAR', outerwear),
    ].join('\n');
  }

  MergeLayerInfo? _findLayer(List<MergeLayerInfo> layers, LayerSlot slot) {
    for (final layer in layers) {
      if (layer.slot == slot) return layer;
    }
    return null;
  }

  String _formatSlotLine(String label, MergeLayerInfo? layer) {
    if (layer == null) return '$label: (none)';
    return '$label: ${layer.typeLabel} (z=${layer.zIndex})';
  }
}
