import 'package:flutter_riverpod/flutter_riverpod.dart';

// Globale App-Navigation: steuert den aktiven Tab.
final tabIndexProvider = StateProvider<int>((ref) => 0);
