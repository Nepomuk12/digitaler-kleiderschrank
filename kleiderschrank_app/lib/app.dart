// よbersicht: Stateful App-Widget, das per Bottom-Navigation zwischen den vier Haupt-Screens
// (Hinzufグgen, Outfit, Verwaltung, Backup) wechselt und das ausgewビhlte Widget rendert.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_state.dart';
import 'features/add_item/add_item_screen.dart';
import 'features/outfit/outfit_screen.dart';
import 'features/wardrobe/wardrobe_screen.dart';
import 'features/backup/backup_screen.dart';

class WardrobeApp extends ConsumerWidget {
  const WardrobeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider); // aktuell gewビhlter Tab
    final pages = [
      const AddItemScreen(), // Kleidung hinzufグgen
      const OutfitScreen(), // Outfits zusammenstellen
      const WardrobeScreen(), // Bestand verwalten
      const BackupScreen(), // Backup-Funktionen
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: pages[index], // zeigt den Screen des aktiven Tabs
        bottomNavigationBar: NavigationBar(
          selectedIndex: index, // markiert den aktiven Tab
          onDestinationSelected: (i) =>
              ref.read(tabIndexProvider.notifier).state = i, // Tab-Wechsel
          destinations: const [
            NavigationDestination(icon: Icon(Icons.add_a_photo), label: 'Add'),
            NavigationDestination(icon: Icon(Icons.checkroom), label: 'Outfit'),
            NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Verwalten'),
            NavigationDestination(icon: Icon(Icons.backup), label: 'Backup'),
          ],
        ),
      ),
    );
  }
}
