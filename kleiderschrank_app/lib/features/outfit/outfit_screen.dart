import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/clothing_item_hive.dart';
import '../add_item/add_item_controller.dart';

class OutfitScreen extends ConsumerStatefulWidget {
  const OutfitScreen({super.key});

  @override
  ConsumerState<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends ConsumerState<OutfitScreen> {
  int topIndex = 0;
  int bottomIndex = 0;
  int shoesIndex = 0;

  int _wrap(int idx, int len) {
    if (len <= 0) return 0;
    var r = idx % len;
    if (r < 0) r += len;
    return r;
  }

  ClothingItem? _current(List<ClothingItem> items, int index) =>
      items.isEmpty ? null : items[index];

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(clothingRepoProvider);

    final tops = repo.loadByCategory(ClothingCategory.top);
    final bottoms = repo.loadByCategory(ClothingCategory.bottom);
    final shoes = repo.loadByCategory(ClothingCategory.shoes);

    topIndex = _wrap(topIndex, tops.length);
    bottomIndex = _wrap(bottomIndex, bottoms.length);
    shoesIndex = _wrap(shoesIndex, shoes.length);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Höhen: Schuhe deutlich kleiner
            final topH = 260.0;
            final bottomH = 260.0;
            final shoesH = 140.0;

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: topH + bottomH + shoesH,
                  child: Stack(
                    children: [
                      // Hintergrund: graue Silhouette (ohne Asset, nur Icon als Platzhalter)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.12,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Icon(
                                Icons.woman,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Outfit "nahtlos" als Column ohne Zwischenräume
                      Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SwipeImage(
                              height: topH,
                              item: _current(tops, topIndex),
                              onNext: () => setState(
                                  () => topIndex = _wrap(topIndex + 1, tops.length)),
                              onPrev: () => setState(
                                  () => topIndex = _wrap(topIndex - 1, tops.length)),
                            ),
                            _SwipeImage(
                              height: bottomH,
                              item: _current(bottoms, bottomIndex),
                              onNext: () => setState(() =>
                                  bottomIndex = _wrap(bottomIndex + 1, bottoms.length)),
                              onPrev: () => setState(() =>
                                  bottomIndex = _wrap(bottomIndex - 1, bottoms.length)),
                            ),
                            _SwipeImage(
                              height: shoesH,
                              item: _current(shoes, shoesIndex),
                              onNext: () => setState(
                                  () => shoesIndex = _wrap(shoesIndex + 1, shoes.length)),
                              onPrev: () => setState(
                                  () => shoesIndex = _wrap(shoesIndex - 1, shoes.length)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SwipeImage extends StatelessWidget {
  const _SwipeImage({
    required this.height,
    required this.item,
    required this.onPrev,
    required this.onNext,
  });

  final double height;
  final ClothingItem? item;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v > 0) onPrev();
        if (v < 0) onNext();
      },
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: item == null
            ? const SizedBox.shrink()
            : Image.file(
                File(item!.normalizedImagePath),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
