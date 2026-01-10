// Übersicht: Startet die Wardrobe-App, initialisiert Hive, registriert alle benötigten Adapter
// und öffnet die Box mit gespeicherten Kleidungsstücken, bevor das Flutter-Widget startet.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'domain/clothing_item_hive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // stellt sicher, dass Flutter-Services vor async-Calls bereitstehen

  await Hive.initFlutter(); // initialisiert Hive in der Flutter-Umgebung
  Hive.registerAdapter(ClothingCategoryAdapter()); // Adapter für Ober-/Unterkategorien
  Hive.registerAdapter(ClothingItemAdapter()); // Adapter für Kleidungsstücke
  Hive.registerAdapter(ColorTagAdapter()); // Adapter für Farbtags
  Hive.registerAdapter(TopTypeAdapter()); // Adapter für Oberteil-Typen
  Hive.registerAdapter(BottomTypeAdapter()); // Adapter für Unterteil-Typen
  Hive.registerAdapter(ShoeTypeAdapter()); // Adapter für Schuh-Typen

  await Hive.openBox<ClothingItem>('clothing_items'); // öffnet die Box mit gespeicherten Kleidungsstücken

  runApp(const ProviderScope(child: WardrobeApp())); // startet die App mit Riverpod-ProviderScope
}
