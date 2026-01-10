// Übersicht: Stateful App-Widget, das per Bottom-Navigation zwischen den vier Haupt-Screens
// (Hinzufügen, Outfit, Verwaltung, Backup) wechselt und das ausgewählte Widget rendert.
import 'package:flutter/material.dart';
import 'features/add_item/add_item_screen.dart';
import 'features/outfit/outfit_screen.dart';
import 'features/wardrobe/wardrobe_screen.dart';
import 'features/backup/backup_screen.dart';

class WardrobeApp extends StatefulWidget {
  const WardrobeApp({super.key});

  @override
  State<WardrobeApp> createState() => _WardrobeAppState();
}

class _WardrobeAppState extends State<WardrobeApp> {
  int index = 0; // aktuell gewählter Tab

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AddItemScreen(), // Kleidung hinzufügen
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
          onDestinationSelected: (i) => setState(() => index = i), // Tab-Wechsel
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
