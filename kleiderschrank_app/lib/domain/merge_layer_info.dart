class MergeLayerInfo {
  final String itemId;
  final String typeLabel;
  final LayerSlot slot;
  final int zIndex; // 0..2, reine Ueberdeckungsreihenfolge
  final String localImagePath;
  final String? brandNotes;
  final WearRelation topBottomRelation;
  final WearRelation bottomShoesRelation;

  const MergeLayerInfo({
    required this.itemId,
    required this.typeLabel,
    required this.slot,
    required this.zIndex,
    required this.localImagePath,
    required this.brandNotes,
    required this.topBottomRelation,
    required this.bottomShoesRelation,
  });
}

enum LayerSlot { top, bottom, shoes }

enum WearRelation { over, tuckedInto, into }
