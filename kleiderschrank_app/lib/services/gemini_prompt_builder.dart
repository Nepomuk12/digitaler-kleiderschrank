import 'package:path/path.dart' as p;

import '../domain/merge_layer_info.dart';

class GeminiPromptBuilder {
  String buildPrompt(List<MergeLayerInfo> layers) {
    final sorted = [...layers]..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    String slotUpper(MergeLayerInfo l) => l.slot.name.toUpperCase();

    final layerLines = sorted.map((layer) {
      final fileName = p.basename(layer.localImagePath);
      return '- file: $fileName, slot: ${slotUpper(layer)}, type: ${layer.typeLabel}, zIndex: ${layer.zIndex}';
    }).join('\n');

    // Use relations from the TOP/BOTTOM layer if available; otherwise default to "over"
    final topLayer = layers.cast<MergeLayerInfo?>().firstWhere(
          (l) => l != null && l.slot.name.toLowerCase() == 'top',
          orElse: () => null,
        );
    final bottomLayer = layers.cast<MergeLayerInfo?>().firstWhere(
          (l) => l != null && l.slot.name.toLowerCase() == 'bottom',
          orElse: () => null,
        );

    final topBottomRelation = topLayer?.topBottomRelation.name ?? 'over';
    final bottomShoesRelation = bottomLayer?.bottomShoesRelation.name ?? 'over';

    return [
      // Core task
      'TASK',
      'Create ONE photorealistic full-body outfit image by COMPOSITING ONLY the provided garment photos.',
      'Do NOT invent, redraw, recolor, relight, enhance, or stylize anything.',
      '',
      // Output framing: nose down + shoes visible
      'OUTPUT / FRAMING (VERY IMPORTANT)',
      '- Final image must include the FULL shoes (toe to heel) and BOTH soles completely visible.',
      '- Add visible floor/ground BELOW the shoes: at least 5–10% of the image height as empty floor margin.',
      '- Do NOT crop the bottom of the image at or near the shoes. No cut-off feet.',
      '- Crop the top so the image starts at the NOSE (nose visible, eyes/forehead/hair NOT visible).',
      '- Keep a full-body framing from nose down to floor, neutral background. Single merged image.',

      '',
      // Hard constraints to avoid color shifts
      'CONSTRAINTS (VERY IMPORTANT)',
      '- Preserve ORIGINAL COLORS, texture, seams, logos, and shading from each garment image exactly.',
      '- NO color correction, NO relighting, NO contrast boost, NO “enhancement”, NO style transfer.',
      '- Do NOT add arms, torso, underwear, or any extra body parts. Remove any remaining body from garment cutouts.',
      '',
      // Ensure shoes are visible
      'SHOE VISIBILITY',
      '- The shoes/foots must remain visible in the final image.',
      '- Do NOT extend pants/jeans over the shoes. The pants hem must NOT cover the shoes, if foots are visible on the provided garment photos with trousers.',
      '- Shoes are mandatory: if any cropping is needed, crop ONLY at the top, NEVER at the bottom.'
      '- Prioritize showing shoes + floor margin over showing full pants length.'
    '',
      // Mapping and layering logic
      'LAYER MAPPING (Y-axis = body region)',
      layerLines,
      '',
      'OCCLUSION RULES (Z-axis = who covers whom)',
      '- z_order: 0=bottom, 1=middle, 2=top',
      '- top_vs_bottom: $topBottomRelation',
      '- bottom_vs_shoes: $bottomShoesRelation',
    ].join('\n');
  }
}
