// Aufgabe: Bilder in Groesse/Qualitaet normalisieren fuer stabile Verarbeitung.
// Hauptfunktionen: Resize auf max. Pixel, JPEG-Encode im Hintergrund-Isolate.
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageNormalizer {
  static Future<File> resizeToMaxPixels({
    required File input,
    required File output,
    int maxPixels = 1200000,
    int jpegQuality = 80,
  }) async {
    // Fuehrt Resize/Encode asynchron im Background-Isolate aus.
    final args = _NormalizeArgs(
      inputPath: input.path,
      outputPath: output.path,
      maxPixels: maxPixels,
      jpegQuality: jpegQuality,
    );

    // läuft in einem Hintergrund-Isolate
    await compute<_NormalizeArgs, void>(_normalizeWorker, args);

    return output;
  }
}

class _NormalizeArgs {
  const _NormalizeArgs({
    required this.inputPath,
    required this.outputPath,
    required this.maxPixels,
    required this.jpegQuality,
  });

  final String inputPath;
  final String outputPath;
  final int maxPixels;
  final int jpegQuality;
}

/// Top-level Funktion (Pflicht für compute)
// Hintergrund-Worker: laedt, resizt und schreibt das Bild.
Future<void> _normalizeWorker(_NormalizeArgs args) async {
  final input = File(args.inputPath);
  final output = File(args.outputPath);

  final bytes = await input.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception('Bild konnte nicht decodiert werden');
  }

  final w = decoded.width;
  final h = decoded.height;
  final pixels = w * h;

  img.Image processed = decoded;

  if (pixels > args.maxPixels) {
    final scale = sqrt(args.maxPixels / pixels);
    final newW = max(1, (w * scale).round());
    final newH = max(1, (h * scale).round());
    processed = img.copyResize(decoded, width: newW, height: newH);
  }

  final jpg = img.encodeJpg(processed, quality: args.jpegQuality);
  await output.writeAsBytes(jpg, flush: true);
}
