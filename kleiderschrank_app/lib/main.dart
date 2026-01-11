// Ãœbersicht: Startet die Wardrobe-App, initialisiert Hive, registriert alle benÃ¶tigten Adapter
// und Ã¶ffnet die Box mit gespeicherten KleidungsstÃ¼cken, bevor das Flutter-Widget startet.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'domain/clothing_item_hive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // stellt sicher, dass Flutter-Services vor async-Calls bereitstehen

  await Hive.initFlutter(); // initialisiert Hive in der Flutter-Umgebung
  Hive.registerAdapter(ClothingCategoryAdapter()); // Adapter fÃ¼r Ober-/Unterkategorien
  Hive.registerAdapter(ClothingItemAdapter()); // Adapter fÃ¼r KleidungsstÃ¼cke
  Hive.registerAdapter(ColorTagAdapter()); // Adapter fÃ¼r Farbtags
  Hive.registerAdapter(TopTypeAdapter()); // Adapter fÃ¼r Oberteil-Typen
  Hive.registerAdapter(BottomTypeAdapter()); // Adapter fÃ¼r Unterteil-Typen
  Hive.registerAdapter(ShoeTypeAdapter()); // Adapter fÃ¼r Schuh-Typen
  Hive.registerAdapter(OutfitOccasionAdapter()); // Adapter für Outfit-Anlässe

  await Hive.openBox<ClothingItem>('clothing_items'); // Ã¶ffnet die Box mit gespeicherten KleidungsstÃ¼cken

  runApp(const ProviderScope(child: WardrobeApp())); // startet die App mit Riverpod-ProviderScope
}

