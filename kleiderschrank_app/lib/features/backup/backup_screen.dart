import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool busy = false;

  Future<void> _export() async {
    setState(() => busy = true);
    try {
      final zip = await BackupService.createBackupZip();
      await Share.shareXFiles(
        [XFile(zip.path)],
        text: 'Kleiderschrank Backup ZIP',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup erstellt – z.B. in Dropbox speichern.')),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => busy = true);
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (res == null || res.files.single.path == null) return;

      final zip = File(res.files.single.path!);
      await BackupService.restoreFromZip(zip);

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Import abgeschlossen'),
          content: const Text(
            'Bitte die App jetzt komplett schließen und neu öffnen, damit die Daten geladen werden.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: busy ? null : _export,
                icon: const Icon(Icons.upload_file),
                label: const Text('Backup erstellen (z.B. Dropbox)'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: busy ? null : _import,
                icon: const Icon(Icons.download),
                label: const Text('Backup ZIP importieren'),
              ),
              const SizedBox(height: 16),
              if (busy) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
