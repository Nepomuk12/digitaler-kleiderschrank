// Aufgabe: Backup/Restore der App-Daten (Hive + Bilder).
// Hauptfunktionen: ZIP erstellen, ZIP importieren, Dateien wiederherstellen.
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupService {
  static const _boxName = 'clothing_items';

  /// Erstellt ZIP im Cache-Verzeichnis und gibt Pfad zurück.
  // Exportiert Hive-Dateien und Images in ein ZIP.
  static Future<File> createBackupZip() async {
    // Sicherstellen, dass Box offen ist, nicht benötigt:
    // Hive.box(_boxName);
    if (!Hive.isBoxOpen(_boxName)) {
    throw Exception('Box "$_boxName" ist nicht geöffnet. App neu starten.');
    }

    final docs = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(docs.path, 'images'));

    // Hive 2.2.x: wir nutzen denselben Ordner, den Hive.initFlutter() i.d.R. verwendet
    final hiveHome = docs.path;

    // Box-Datei(en)
    final hiveFile = File(p.join(hiveHome, '$_boxName.hive'));
    final hiveLockFile = File(p.join(hiveHome, '$_boxName.hive.lock'));

    final cache = await getTemporaryDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final zipFile = File(p.join(cache.path, 'wardrobe_backup_$ts.zip'));

    final archive = Archive();

    // 1) Hive Box-Datei
    if (await hiveFile.exists()) {
      final bytes = await hiveFile.readAsBytes();
      archive.addFile(
        ArchiveFile('hive/${p.basename(hiveFile.path)}', bytes.length, bytes),
      );
    } else {
      throw Exception('Hive-Datei nicht gefunden: ${hiveFile.path}');
    }

    // Lock-Datei ist optional (nicht immer vorhanden)
    if (await hiveLockFile.exists()) {
      final bytes = await hiveLockFile.readAsBytes();
      archive.addFile(
        ArchiveFile('hive/${p.basename(hiveLockFile.path)}', bytes.length, bytes),
      );
    }

    // 2) Bilderordner
    if (await imagesDir.exists()) {
      await for (final entity in imagesDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final rel = p.relative(entity.path, from: docs.path); // images/...
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile(rel, bytes.length, bytes));
        }
      }
    }

    // ZIP schreiben
    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) {
      throw Exception('ZIP konnte nicht erzeugt werden');
    }
    await zipFile.writeAsBytes(zipBytes, flush: true);

    return zipFile;
  }

  /// Importiert ZIP: überschreibt Hive-Datei + images/*
  /// Hinweis: Danach App neu starten (oder mindestens Hive neu öffnen).
  // Schliest Hive, schreibt Dateien aus dem ZIP und legt Bilder ab.
  static Future<void> restoreFromZip(File zip) async {
    // Hive schließen, damit Datei nicht gelockt ist
    await Hive.close();

    final bytes = await zip.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final docs = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(docs.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Hive 2.2.x: wir nutzen denselben Ordner, den Hive.initFlutter() i.d.R. verwendet
    final hiveHome = docs.path;

    final targetHiveFile = File(p.join(hiveHome, '$_boxName.hive'));
    final targetHiveLockFile = File(p.join(hiveHome, '$_boxName.hive.lock'));

    // Dateien aus ZIP schreiben
    for (final f in archive) {
      if (!f.isFile) continue;

      final name = f.name;

      if (name.startsWith('hive/')) {
        final base = p.basename(name);

        if (base == '$_boxName.hive') {
          await targetHiveFile.parent.create(recursive: true);
          await targetHiveFile.writeAsBytes(f.content as List<int>, flush: true);
        } else if (base == '$_boxName.hive.lock') {
          await targetHiveLockFile.parent.create(recursive: true);
          await targetHiveLockFile.writeAsBytes(f.content as List<int>, flush: true);
        }
      } else if (name.startsWith('images/')) {
        final outFile = File(p.join(docs.path, name));
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(f.content as List<int>, flush: true);
      }
    }

    debugPrint('Restore fertig. Bitte App neu starten.');
  }
}
