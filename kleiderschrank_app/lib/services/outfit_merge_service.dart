// lib/services/outfit_merge_service.dart
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';


import 'package:path_provider/path_provider.dart';

import '../config/merge_config.dart';

enum MergeLayer { top, middle, bottom }

extension MergeLayerZ on MergeLayer {
  int get z {
    switch (this) {
      case MergeLayer.top:
        return 2;
      case MergeLayer.middle:
        return 1;
      case MergeLayer.bottom:
        return 0;
    }
  }
}

/// Minimal-Interface: nur Bildpfad + Reihenfolge (stabil)
class MergeInput {
  final String normalizedImagePath;
  final int categoryOrder; // 0=top,1=bottom,2=shoes (nur für stable sort im Fallback)

  const MergeInput({
    required this.normalizedImagePath,
    required this.categoryOrder,
  });
}

class OutfitMergeService {
  const OutfitMergeService();

  Future<String> mergeToTempPng({
    required MergeInput top,
    required MergeInput bottom,
    required MergeInput shoes,
    required MergeLayer topLayer,
    required MergeLayer bottomLayer,
    required MergeLayer shoesLayer,
  }) async {
    switch (MergeConfig.algorithm) {
      case OutfitMergeAlgorithm.smartAnchoredZonesV1:
        // NEU: Dynamische Höhe (≈ Summe der Einzelbilder), Overlap nur in den Übergängen
    return _mergeStackedDynamicHeightSmartMask(
      top: top,
      bottom: bottom,
      shoes: shoes,
      topLayer: topLayer,
      bottomLayer: bottomLayer,
      shoesLayer: shoesLayer,
    );

      case OutfitMergeAlgorithm.simpleLayerOverlay:
        return _mergeSimpleOverlay(
          top: top,
          bottom: bottom,
          shoes: shoes,
          topLayer: topLayer,
          bottomLayer: bottomLayer,
          shoesLayer: shoesLayer,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // 1) Dynamic height merge: Höhe ≈ Summe der Inhalte (cropped by alpha),
  //    Overlap nur in definierten Übergangsbereichen.
  // ---------------------------------------------------------------------------

  Future<String> _mergeStackedDynamicHeightSmartMask({
  required MergeInput top,
  required MergeInput bottom,
  required MergeInput shoes,
  required MergeLayer topLayer,
  required MergeLayer bottomLayer,
  required MergeLayer shoesLayer,
}) async {
  final canvasW = MergeConfig.outWidth.toInt();

  final topImg = await _loadUiImage(top.normalizedImagePath);
  final bottomImg = await _loadUiImage(bottom.normalizedImagePath);
  final shoesImg = await _loadUiImage(shoes.normalizedImagePath);

  final topCrop = await _croppedByAlpha(topImg);
  final bottomCrop = await _croppedByAlpha(bottomImg);
  final shoesCrop = await _croppedByAlpha(shoesImg);

  final topPlaced = _placeCroppedToWidth(topImg, topCrop, MergeConfig.outWidth.toDouble());
  final bottomPlaced = _placeCroppedToWidth(bottomImg, bottomCrop, MergeConfig.outWidth.toDouble());
  final shoesPlaced = _placeCroppedToWidth(shoesImg, shoesCrop, MergeConfig.outWidth.toDouble());

  final overlapWaist = min(
    MergeConfig.waistOverlapPx,
    min(topPlaced.dstH, bottomPlaced.dstH) * 0.35,
  );
  final overlapAnkle = min(
    MergeConfig.ankleOverlapPx,
    min(bottomPlaced.dstH, shoesPlaced.dstH) * 0.35,
  );

  final canvasH = max(
    1.0,
    topPlaced.dstH + bottomPlaced.dstH + shoesPlaced.dstH - overlapWaist - overlapAnkle,
  ).toInt();

  final yTop = 0.0;
  final yBottom = topPlaced.dstH - overlapWaist;
  final yShoes = topPlaced.dstH + bottomPlaced.dstH - overlapWaist - overlapAnkle;

  // 1) Render jedes Teil in ein gleich großes RGBA-Canvas (transparent)
  final topRgba = await _renderPlacedRgba(
    topImg,
    topPlaced.src,
    topPlaced.dstAt(yTop),
    canvasW,
    canvasH,
  );
  final bottomRgba = await _renderPlacedRgba(
    bottomImg,
    bottomPlaced.src,
    bottomPlaced.dstAt(yBottom),
    canvasW,
    canvasH,
  );
  final shoesRgba = await _renderPlacedRgba(
    shoesImg,
    shoesPlaced.src,
    shoesPlaced.dstAt(yShoes),
    canvasW,
    canvasH,
  );

  final bgTop = _estimateBg(topRgba, canvasW, canvasH);
  final bgBottom = _estimateBg(bottomRgba, canvasW, canvasH);
  final bgShoes = _estimateBg(shoesRgba, canvasW, canvasH);

  // 2) Output: weißer Hintergrund, dann Zonen befüllen
  final out = Uint8List(canvasW * canvasH * 4);
  for (int i = 0; i < out.length; i += 4) {
    out[i] = 255;
    out[i + 1] = 255;
    out[i + 2] = 255;
    out[i + 3] = 255;
  }

  final waistStart = yBottom.toInt();
  final waistEnd = (yBottom + overlapWaist).toInt();

  final ankleStart = yShoes.toInt();
  final ankleEnd = (yShoes + overlapAnkle).toInt();

  // Exklusive Zonen (Foreground-only)
  _blitZone(out, topRgba, canvasW, canvasH, 0, waistStart);
  _blitZone(out, bottomRgba, canvasW, canvasH, waistEnd, ankleStart);
  _blitZone(out, shoesRgba, canvasW, canvasH, ankleEnd, canvasH);

  // Waist overlap: Top <-> Bottom (intelligent)
  _blendOverlap(
    out: out,
    canvasW: canvasW,
    y0: waistStart,
    y1: waistEnd,
    a: topRgba,
    b: bottomRgba,
    bgA: bgTop,
    bgB: bgBottom,
    layerA: topLayer,
    layerB: bottomLayer,
    waistY: (waistStart + waistEnd) ~/ 2,
    isWaist: true,
  );

  // Ankle overlap: Bottom <-> Shoes (intelligent)
  _blendOverlap(
    out: out,
    canvasW: canvasW,
    y0: ankleStart,
    y1: ankleEnd,
    a: bottomRgba,
    b: shoesRgba,
    bgA: bgBottom,
    bgB: bgShoes,
    layerA: bottomLayer,
    layerB: shoesLayer,
    waistY: 0,
    isWaist: false,
  );

  final pngBytes = await _rgbaToPng(out, canvasW, canvasH);

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(pngBytes, flush: true);
  return file.path;
}


  // ---------------------------------------------------------------------------
  // 2) Fallback overlay (debug)
  // ---------------------------------------------------------------------------

  Future<String> _mergeSimpleOverlay({
    required MergeInput top,
    required MergeInput bottom,
    required MergeInput shoes,
    required MergeLayer topLayer,
    required MergeLayer bottomLayer,
    required MergeLayer shoesLayer,
  }) async {
    final canvasW = MergeConfig.outWidth;
    final canvasH = MergeConfig.outHeight;

    final layers = <({int z, MergeInput item})>[
      (z: topLayer.z, item: top),
      (z: bottomLayer.z, item: bottom),
      (z: shoesLayer.z, item: shoes),
    ];

    layers.sort((a, b) {
      final c = a.z.compareTo(b.z);
      if (c != 0) return c;
      return a.item.categoryOrder.compareTo(b.item.categoryOrder);
    });

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, canvasW.toDouble(), canvasH.toDouble()),
    );

    for (final entry in layers) {
      final img = await _loadUiImage(entry.item.normalizedImagePath);
      _drawContain(canvas, img, canvasW.toDouble(), canvasH.toDouble(), ui.Paint());
    }

    final picture = recorder.endRecording();
    final outImg = await picture.toImage(canvasW, canvasH);
    final bytes = await outImg.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('PNG encoding failed');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    return file.path;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<ui.Image> _loadUiImage(String path) async {
    final data = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _drawContain(ui.Canvas canvas, ui.Image img, double canvasW, double canvasH, ui.Paint paint) {
    final iw = img.width.toDouble();
    final ih = img.height.toDouble();
    final s = min(canvasW / iw, canvasH / ih);
    final dw = iw * s;
    final dh = ih * s;
    final dx = (canvasW - dw) / 2;
    final dy = (canvasH - dh) / 2;
    canvas.drawImageRect(img, ui.Rect.fromLTWH(0, 0, iw, ih), ui.Rect.fromLTWH(dx, dy, dw, dh), paint);
  }

  void _drawClippedAt(
    ui.Canvas canvas,
    ui.Image img,
    ui.Rect src,
    ui.Rect dst,
    ui.Rect clip, {
    required double opacity,
  }) {
    canvas.save();
    canvas.clipRect(clip);
    final paint = ui.Paint()..color = ui.Color.fromRGBO(255, 255, 255, opacity);
    canvas.drawImageRect(img, src, dst, paint);
    canvas.restore();
  }

  Future<({int minY, int maxY})> _alphaBounds(ui.Image img) async {
    final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bd == null) return (minY: 0, maxY: img.height - 1);

    final bytes = bd.buffer.asUint8List();
    final w = img.width;
    final h = img.height;

    final step = max(1, MergeConfig.bboxStep);
    final thr = MergeConfig.alphaThreshold;

    int minY = h - 1;
    int maxY = 0;
    bool found = false;

    for (int y = 0; y < h; y += step) {
      bool rowHas = false;
      final rowStart = y * w * 4;
      for (int x = 0; x < w; x += step) {
        final a = bytes[rowStart + x * 4 + 3];
        if (a > thr) {
          rowHas = true;
          break;
        }
      }
      if (rowHas) {
        found = true;
        minY = min(minY, y);
        maxY = max(maxY, y);
      }
    }

    if (!found) return (minY: 0, maxY: h - 1);

    minY = max(0, minY - step);
    maxY = min(h - 1, maxY + step);
    return (minY: minY, maxY: maxY);
  }

  Future<ui.Rect> _croppedByAlpha(ui.Image img) async {
    final b = await _alphaBounds(img);
    final iw = img.width.toDouble();
    final minY = b.minY.toDouble();
    final maxY = b.maxY.toDouble();
    final h = max(1.0, (maxY - minY).abs());
    return ui.Rect.fromLTWH(0, minY, iw, h);
  }

  _Placed _placeCroppedToWidth(ui.Image img, ui.Rect cropSrc, double canvasW) {
    final iw = img.width.toDouble();
    final scale = canvasW / iw;
    final dstH = cropSrc.height * scale;
    return _Placed(
      src: cropSrc,
      dstW: canvasW,
      dstH: dstH,
      scale: scale,
    );
  }
}

class _Placed {
  final ui.Rect src;
  final double dstW;
  final double dstH;
  final double scale;

  const _Placed({
    required this.src,
    required this.dstW,
    required this.dstH,
    required this.scale,
  });

  ui.Rect dstAt(double y) => ui.Rect.fromLTWH(0, y, dstW, dstH);
}
Future<Uint8List> _renderPlacedRgba(
  ui.Image img,
  ui.Rect src,
  ui.Rect dst,
  int canvasW,
  int canvasH,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, canvasW.toDouble(), canvasH.toDouble()));
  canvas.drawImageRect(img, src, dst, ui.Paint());
  final picture = recorder.endRecording();
  final outImg = await picture.toImage(canvasW, canvasH);
  final bd = await outImg.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (bd == null) throw StateError('rawRgba failed');
  return bd.buffer.asUint8List();
}

({int r, int g, int b}) _estimateBg(Uint8List rgba, int w, int h) {
  const int k = 24;
  int sumR = 0, sumG = 0, sumB = 0, n = 0;

  void add(int x0, int y0) {
    for (int y = y0; y < min(y0 + k, h); y++) {
      for (int x = x0; x < min(x0 + k, w); x++) {
        final i = (y * w + x) * 4;
        sumR += rgba[i];
        sumG += rgba[i + 1];
        sumB += rgba[i + 2];
        n++;
      }
    }
  }

  add(0, 0);
  add(max(0, w - k), 0);
  add(0, max(0, h - k));
  add(max(0, w - k), max(0, h - k));

  if (n == 0) return (r: 255, g: 255, b: 255);
  return (r: (sumR ~/ n), g: (sumG ~/ n), b: (sumB ~/ n));
}

bool _isBackgroundPx(int r, int g, int b, ({int r, int g, int b}) bg) {
  final int tol = MergeConfig.bgTol;
  final dr = (r - bg.r).abs();
  final dg = (g - bg.g).abs();
  final db = (b - bg.b).abs();
  final (h, s, v) = _rgbToHsv(r, g, b);
  final rgbClose = (dr + dg + db) <= tol * 3;
  final satOk = s <= MergeConfig.bgSatMax;
  final valOk = v >= MergeConfig.bgValMin;
  return rgbClose && satOk && valOk;
}

bool _isBodyPx(int r, int g, int b) {
  final (h, s, v) = _rgbToHsv(r, g, b);
  final isHueOk = (h >= MergeConfig.bodyHueMin && h <= MergeConfig.bodyHueMax);
  return isHueOk && s <= MergeConfig.bodySatMax && v >= MergeConfig.bodyValMin;
}

(double, double, double) _rgbToHsv(int r, int g, int b) {
  final rf = r / 255.0, gf = g / 255.0, bf = b / 255.0;
  final maxv = max(rf, max(gf, bf));
  final minv = min(rf, min(gf, bf));
  final d = maxv - minv;

  double h;
  if (d == 0) {
    h = 0;
  } else if (maxv == rf) {
    h = 60 * (((gf - bf) / d) % 6);
  } else if (maxv == gf) {
    h = 60 * (((bf - rf) / d) + 2);
  } else {
    h = 60 * (((rf - gf) / d) + 4);
  }
  if (h < 0) h += 360;

  final s = maxv == 0 ? 0.0 : d / maxv;
  final v = maxv;
  return (h, s, v);
}

void _blitZone(
  Uint8List out,
  Uint8List src,
  int w,
  int h,
  int y0,
  int y1,
) {
  final yy0 = max(0, min(h, y0));
  final yy1 = max(0, min(h, y1));
  for (int y = yy0; y < yy1; y++) {
    final row = (y * w) * 4;
    for (int x = 0; x < w; x++) {
      final i = row + x * 4;
      final r = src[i], g = src[i + 1], b = src[i + 2], a = src[i + 3];
      if (a == 0) continue;
      out[i] = r; out[i + 1] = g; out[i + 2] = b; out[i + 3] = 255;
    }
  }
}

void _blendOverlap({
  required Uint8List out,
  required int canvasW,
  required int y0,
  required int y1,
  required Uint8List a,
  required Uint8List b,
  required ({int r, int g, int b}) bgA,
  required ({int r, int g, int b}) bgB,
  required MergeLayer layerA,
  required MergeLayer layerB,
  required int waistY,
  required bool isWaist,
}) {
  final h = out.length ~/ (canvasW * 4);
  final yy0 = max(0, min(h, y0));
  final yy1 = max(0, min(h, y1));

  final aWins = layerA.z >= layerB.z;
  final primary = aWins ? a : b;
  final secondary = aWins ? b : a;
  final bgP = aWins ? bgA : bgB;
  final bgS = aWins ? bgB : bgA;
  final pLayer = aWins ? layerA : layerB;
  final sLayer = aWins ? layerB : layerA;

  final int middleBand = MergeConfig.waistMiddleBandPx;
  final int bodyGuardBand = MergeConfig.bodyGuardBandPx;
  final bool enableFeather = MergeConfig.featherPx > 0;
  final double overlapH = max(1, yy1 - yy0).toDouble();
  final int torsoSideGuard = MergeConfig.torsoSideGuardPx;
  final int scanStep = max(1, MergeConfig.torsoScanStep);

  for (int y = yy0; y < yy1; y++) {
    final inMiddleBand = isWaist && ((y - waistY).abs() <= middleBand);
    final inGuardBand = isWaist && ((y - waistY).abs() <= bodyGuardBand);

    bool preferSecondary = false;
    if (inMiddleBand) {
      if (pLayer != MergeLayer.middle && sLayer == MergeLayer.middle) {
        preferSecondary = true;
      }
    }

    final row = (y * canvasW) * 4;

    int? torsoLeft;
    int? torsoRight;
    if (isWaist) {
      for (int x = 0; x < canvasW; x += scanStep) {
        final idx = row + x * 4;
        final pr = primary[idx], pg = primary[idx + 1], pb = primary[idx + 2], pa = primary[idx + 3];
        final pFg = pa != 0 && !_isBackgroundPx(pr, pg, pb, bgP);
        if (pFg) {
          torsoLeft = x + torsoSideGuard;
          break;
        }
      }
      for (int x = canvasW - 1; x >= 0; x -= scanStep) {
        final idx = row + x * 4;
        final pr = primary[idx], pg = primary[idx + 1], pb = primary[idx + 2], pa = primary[idx + 3];
        final pFg = pa != 0 && !_isBackgroundPx(pr, pg, pb, bgP);
        if (pFg) {
          torsoRight = x - torsoSideGuard;
          break;
        }
      }
      if (torsoLeft != null && torsoRight != null) {
        torsoLeft = max(0, torsoLeft!);
        torsoRight = min(canvasW - 1, torsoRight!);
      }
    }

    for (int x = 0; x < canvasW; x++) {
      final i = row + x * 4;

      final pr = primary[i], pg = primary[i + 1], pb = primary[i + 2], pa = primary[i + 3];
      final sr = secondary[i], sg = secondary[i + 1], sb = secondary[i + 2], sa = secondary[i + 3];

      final pFg = pa != 0 && !_isBackgroundPx(pr, pg, pb, bgP);
      final sFg = sa != 0 && !_isBackgroundPx(sr, sg, sb, bgS);

      final inTorsoGuard = isWaist && torsoLeft != null && torsoRight != null && (x < torsoLeft! || x > torsoRight!);
      if (inTorsoGuard) {
        if (pFg) {
          out[i] = pr; out[i + 1] = pg; out[i + 2] = pb; out[i + 3] = 255;
        } else if (sFg) {
          out[i] = sr; out[i + 1] = sg; out[i + 2] = sb; out[i + 3] = 255;
        }
        continue;
      }

      final pIsBody = inGuardBand && pFg && _isBodyPx(pr, pg, pb);
      final sIsBody = inGuardBand && sFg && _isBodyPx(sr, sg, sb);

      bool primaryWins = false;
      bool secondaryWins = false;
      bool bodyConflict = false;

      if (inGuardBand && pFg && sFg) {
        if (pIsBody && !sIsBody) {
          secondaryWins = true;
          bodyConflict = true;
        } else if (sIsBody && !pIsBody) {
          primaryWins = true;
          bodyConflict = true;
        } else if (pIsBody && sIsBody) {
          primaryWins = true;
          bodyConflict = true;
        }
      }

      if (!bodyConflict) {
        final secondaryPreferred = preferSecondary && sFg;
        final allowPrimary = !(pIsBody && sFg);
        primaryWins = pFg && allowPrimary && !secondaryPreferred;
        secondaryWins = sFg && (!primaryWins);
      }

      if (enableFeather && pFg && sFg && !bodyConflict) {
        final double t = (y - yy0) / overlapH;
        final bool primaryDominates = primaryWins && !secondaryWins;
        final double rawWeight = primaryDominates
            ? ((t - 0.5) * 0.6 + 0.2).clamp(0.0, 0.35)
            : ((t - 0.5) * 0.6 + 0.65).clamp(0.65, 1.0);
        final weight = rawWeight.toDouble();
        out[i] = (pr * (1 - weight) + sr * weight).round();
        out[i + 1] = (pg * (1 - weight) + sg * weight).round();
        out[i + 2] = (pb * (1 - weight) + sb * weight).round();
        out[i + 3] = 255;
        continue;
      }

      if (primaryWins && pFg) {
        out[i] = pr; out[i + 1] = pg; out[i + 2] = pb; out[i + 3] = 255;
      } else if (secondaryWins) {
        out[i] = sr; out[i + 1] = sg; out[i + 2] = sb; out[i + 3] = 255;
      }
    }
  }
}

Future<Uint8List> _rgbaToPng(Uint8List rgba, int w, int h) async {
  final completer = Completer<Uint8List>();
  ui.decodeImageFromPixels(
    rgba,
    w,
    h,
    ui.PixelFormat.rgba8888,
    (ui.Image img) async {
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) {
        completer.completeError(StateError('png encode failed'));
        return;
      }
      completer.complete(bd.buffer.asUint8List());
    },
  );
  return completer.future;
}
