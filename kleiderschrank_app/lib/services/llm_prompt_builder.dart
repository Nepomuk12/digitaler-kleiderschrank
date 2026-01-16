import '../domain/merge_layer_info.dart';

class LlmPromptBuilder {
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
      'Create ONE photorealistic full-body outfit image by using  the garments shown in the provided CONTACT SHEET image. Do NOT recolor, relight, enhance, or stylize.',

      'INPUT: CONTACT SHEET (2x2 grid)',
      '- Each image represents a single clothing item.',
      '- Top-left cell: TOP garment',
      '- Top-right cell: OUTERWEAR garment (optional). If empty/placeholder, ignore.',
      '- Bottom-left cell: BOTTOM garment',
      '- Bottom-right cell: SHOES garment',

      'OPERATION:',
      '- Stack the provided clothing images vertically to form one full outfit.',
      '- Crop the final image to the minimal bounding box containing all non-transparent pixels.',

      'REQUIREMENTS (VERY IMPORTANT):',
      '- Preserve ORIGINAL COLORS, texture, seams, logos, and shading of each garment exactly.',
      '- NO color correction, NO relighting, NO contrast boost, NO enhancement, NO style transfer.',
      '- Do NOT add extra body parts (arms/torso/underwear). Do not hallucinate new clothing.',
      '- Output framing: include FULL shoes and add visible floor below shoes (at least 8% image height). Never crop bottom at feet.',
      '- Crop ONLY at the top: start at NOSE (nose visible, eyes/forehead/hair NOT visible). Neutral background.',

      'LAYER / OCCLUSION RULES',
      '- Use zIndex values only as occlusion priority (higher z covers lower z).',
      '- Explicit relations:',
      '  - top_vs_bottom: $topBottomRelation',
      '  - bottom_vs_shoes: $bottomShoesRelation',
      '  - outerwear_vs_top: over',
      '  - outerwear_vs_bottom: over',
      '',
      //'SLOTS',
      //_formatSlotLine('TOP', top),
      //_formatSlotLine('BOTTOM', bottom),
      //_formatSlotLine('SHOES', shoes),
      //_formatSlotLine('OUTERWEAR', outerwear),

      //'hINT:',
      //'- Do NOT generate a body, skin, face, limbs, or anatomy.',
      //'- Do NOT generate lighting, shadows, gradients, or background.',
      //'- Do NOT recolor, relight, sharpen, blur, or stylize.',
      //'- Do NOT add or hallucinate any pixels not present in the input images.',
      //'- Do NOT ask if image should be generated or recommend wearing, just create image.',

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
