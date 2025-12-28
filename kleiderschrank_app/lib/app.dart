import 'package:flutter/material.dart';
import 'features/add_item/add_item_screen.dart';
import 'features/outfit/outfit_screen.dart';
import 'features/wardrobe/wardrobe_screen.dart';


class WardrobeApp extends StatefulWidget {
  const WardrobeApp({super.key});

  @override
  State<WardrobeApp> createState() => _WardrobeAppState();
}

class _WardrobeAppState extends State<WardrobeApp> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AddItemScreen(),
      const OutfitScreen(),
      const WardrobeScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.add_a_photo), label: 'Add'),
            NavigationDestination(icon: Icon(Icons.checkroom), label: 'Outfit'),
            NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Verwalten'),
                              ],
          
        ),
      ),
    );
  }
}
