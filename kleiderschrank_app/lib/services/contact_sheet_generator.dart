import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/merge_layer_info.dart';

class ContactSheetGenerator {
  Future<String> createOutfitContactSheet({
    required List<MergeLayerInfo> layers,
    int cellSizePx = 768,
  }) async {
    final labelHeight = 64;
    final cellFullHeight = cellSizePx + labelHeight;
    final sheetWidth = cellSizePx * 2;
    final sheetHeight = cellFullHeight * 2;

    final canvas = img.Image(width: sheetWidth, height: sheetHeight);
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

    final top = _findLayer(layers, LayerSlot.top);
    final bottom = _findLayer(layers, LayerSlot.bottom);
    final shoes = _findLayer(layers, LayerSlot.shoes);
    final outerwear = _findLayer(layers, LayerSlot.outerwear);

    _drawCell(
      canvas,
      x: 0,
      y: 0,
      cellSizePx: cellSizePx,
      labelHeight: labelHeight,
      layer: top,
      placeholderText: 'TOP',
    );
    _drawCell(
      canvas,
      x: cellSizePx,
      y: 0,
      cellSizePx: cellSizePx,
      labelHeight: labelHeight,
      layer: outerwear,
      placeholderText: 'OUTERWEAR (optional)',
    );
    _drawCell(
      canvas,
      x: 0,
      y: cellFullHeight,
      cellSizePx: cellSizePx,
      labelHeight: labelHeight,
      layer: bottom,
      placeholderText: 'BOTTOM',
    );
    _drawCell(
      canvas,
      x: cellSizePx,
      y: cellFullHeight,
      cellSizePx: cellSizePx,
      labelHeight: labelHeight,
      layer: shoes,
      placeholderText: 'SHOES',
    );

    final dir = await getTemporaryDirectory();
    final fileName = 'outfit_contact_sheet_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = p.join(dir.path, fileName);
    final jpg = img.encodeJpg(canvas, quality: 85);
    await File(filePath).writeAsBytes(jpg, flush: true);
    return filePath;
  }

  MergeLayerInfo? _findLayer(List<MergeLayerInfo> layers, LayerSlot slot) {
    for (final layer in layers) {
      if (layer.slot == slot) return layer;
    }
    return null;
  }

  void _drawCell(
    img.Image canvas, {
    required int x,
    required int y,
    required int cellSizePx,
    required int labelHeight,
    required MergeLayerInfo? layer,
    required String placeholderText,
  }) {
    final imageX = x;
    final imageY = y;
    final imageW = cellSizePx;
    final imageH = cellSizePx;
    final labelY = y + cellSizePx;

    if (layer == null) {
      _drawCenteredText(
        canvas,
        imageX,
        imageY,
        imageW,
        imageH,
        placeholderText,
      );
      _drawLabel(canvas, x, labelY, labelHeight, '$placeholderText (none)');
      return;
    }

    final source = File(layer.localImagePath);
    if (source.existsSync()) {
      final bytes = source.readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        _drawContainedImage(canvas, decoded, imageX, imageY, imageW, imageH);
      }
    }

    final label = '${_slotLabel(layer.slot)} z=${layer.zIndex} ${layer.typeLabel}';
    _drawLabel(canvas, x, labelY, labelHeight, label);
  }

  void _drawContainedImage(
    img.Image canvas,
    img.Image src,
    int x,
    int y,
    int width,
    int height,
  ) {
    final scale = _containScale(src.width, src.height, width, height);
    final targetW = (src.width * scale).round();
    final targetH = (src.height * scale).round();
    final resized = img.copyResize(src, width: targetW, height: targetH);
    final dx = x + ((width - targetW) ~/ 2);
    final dy = y + ((height - targetH) ~/ 2);
    img.compositeImage(canvas, resized, dstX: dx, dstY: dy);
  }

  double _containScale(int srcW, int srcH, int dstW, int dstH) {
    final scaleX = dstW / srcW;
    final scaleY = dstH / srcH;
    return scaleX < scaleY ? scaleX : scaleY;
  }

  void _drawCenteredText(
    img.Image canvas,
    int x,
    int y,
    int width,
    int height,
    String text,
  ) {
    final font = img.arial24;
    final textW = _measureTextWidth(font, text);
    final textH = font.lineHeight;
    final dx = x + ((width - textW) ~/ 2);
    final dy = y + ((height - textH) ~/ 2);
    img.drawString(
      canvas,
      text,
      font: font,
      x: dx,
      y: dy,
      color: img.ColorRgb8(40, 40, 40),
    );
  }

  void _drawLabel(img.Image canvas, int x, int y, int height, String text) {
    final font = img.arial14;
    img.drawString(
      canvas,
      text,
      font: font,
      x: x + 8,
      y: y + ((height - font.lineHeight) ~/ 2),
      color: img.ColorRgb8(20, 20, 20),
    );
  }

  int _measureTextWidth(img.BitmapFont font, String text) {
    var width = 0;
    for (final codeUnit in text.codeUnits) {
      width += font.characters[codeUnit]?.xAdvance ?? (font.base ~/ 2);
    }
    return width;
  }

  String _slotLabel(LayerSlot slot) {
    switch (slot) {
      case LayerSlot.top:
        return 'TOP';
      case LayerSlot.bottom:
        return 'BOTTOM';
      case LayerSlot.shoes:
        return 'SHOES';
      case LayerSlot.outerwear:
        return 'OUTERWEAR';
    }
  }
}
