// lib/config/merge_config.dart

enum OutfitMergeAlgorithm {
  /// Phase 1: lokal, heuristische Fixpunkte + Overlap-Zonen + maskenbasierte Regeln
  smartAnchoredZonesV1,

  /// Fallback (reines Overlay) – kann zum Debuggen genutzt werden
  simpleLayerOverlay,
}

class MergeConfig {
  static const OutfitMergeAlgorithm algorithm = OutfitMergeAlgorithm.smartAnchoredZonesV1;

  /// Output-Größe des Merge-Previews (Dialog)
  static const int outWidth = 1024;
  static const int outHeight = 1536;

  /// Fixpunkte (in % der Höhe)
  static const double waistLineY = 0.52; // Übergang Top->Bottom
  static const double ankleLineY = 0.84; // Übergang Bottom->Shoes

  /// Überlappung an den Übergängen (in Pixel)
  /// Mehr Overlap reduziert Doppelungen, erhöht aber das Risiko, dass Details wegfallen.
  static const double waistOverlapPx = 140;  // vorher 90
  static const double ankleOverlapPx = 130;  // vorher 90

  /// Alpha-Schwelle für Bounding-Box (bei transparentem Hintergrund)
  static const int alphaThreshold = 12;

  /// Sampling Step für Bounding-Box (Performance)
  static const int bboxStep = 3;

  /// Glättung: im Overlap die obere Ebene leicht transparenter (0..1)
  /// Aggressiv = eher weniger transparent, damit oben gewinnt.
  static const double overlapTopAlpha = 0.98; // vorher 0.92

  /// ---------------------------
  /// SmartMask-Parameter (neu)
  /// ---------------------------

  /// Hintergrund-Erkennung (höher = aggressiver: mehr wird als Hintergrund maskiert)
  static const int bgTol = 28; // 38..65 sinnvoll
  static const double bgSatMax = 0.18;     // Hintergrund ist entsättigt
  static const double bgValMin = 0.75;     // Hintergrund ist hell

  /// Bund-Bandbreite, in der Middle-Layer bevorzugt werden darf (px)
  static const int waistMiddleBandPx = 18; // vorher implizit ~14
  static const int bodyGuardBandPx = 22;   // Body-Regel nur in dieser Bundzone aktiv

  /// Pose: Minimum-Confidence für Landmarks (aggressiv = niedriger)
  static const double poseMinConf = 0.30; // vorher typ. 0.35

  /// Body-Erkennung (HSV), aggressiv großzügig
  /// Hue in Grad, S/V 0..1
  static const double bodyHueMin = 10;   // vorher enger
  static const double bodyHueMax = 58;
  static const double bodySatMax = 0.38;
  static const double bodyValMin = 0.50;
  static const int featherPx = 8;        // weiche Kante für Overlap
  static const int torsoSideGuardPx = 18;   // wie stark wir am Rand "Top gewinnt" erzwingen
  static const int torsoScanStep = 4;       // performance

  static const bool debug = false;
}
