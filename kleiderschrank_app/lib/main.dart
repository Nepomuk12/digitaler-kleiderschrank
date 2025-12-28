import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'domain/clothing_item_hive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ClothingCategoryAdapter());
  Hive.registerAdapter(ClothingItemAdapter());
  Hive.registerAdapter(ColorTagAdapter());
  Hive.registerAdapter(TopTypeAdapter());
  Hive.registerAdapter(BottomTypeAdapter());
  Hive.registerAdapter(ShoeTypeAdapter());

  await Hive.openBox<ClothingItem>('clothing_items');

  runApp(const ProviderScope(child: WardrobeApp()));
}
