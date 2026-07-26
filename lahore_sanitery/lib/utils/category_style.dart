import 'package:flutter/material.dart';

/// Maps each category name to its display color and thumbnail image,
/// per the finalized Stitch design. Add a new entry here whenever a
/// new category is introduced in Phase 6 (real data).
class CategoryStyle {
  final Color color;
  final String imagePath;

  const CategoryStyle({required this.color, required this.imagePath});
}

const Map<String, CategoryStyle> categoryStyles = {
  'Pipes': CategoryStyle(
    color: Colors.blue,
    imagePath: 'assets/categories/pipes.jpg',
  ),
  'Nuts & Bolts': CategoryStyle(
    color: Colors.blueGrey,
    imagePath: 'assets/categories/nuts_bolts.jpg',
  ),
  'Taps': CategoryStyle(
    color: Colors.teal,
    imagePath: 'assets/categories/taps.jpg',
  ),
  'Fittings': CategoryStyle(
    color: Colors.orange,
    imagePath: 'assets/categories/fittings.jpg',
  ),
  'Valves': CategoryStyle(
    color: Colors.red,
    imagePath: 'assets/categories/valves.jpg',
  ),
  'Tools': CategoryStyle(
    color: Colors.purple,
    imagePath: 'assets/categories/tools.jpg',
  ),
};

/// Falls back to a neutral style if a category isn't in the map yet,
/// so the app never crashes on an unrecognized category.
CategoryStyle styleFor(String category) {
  return categoryStyles[category] ??
      const CategoryStyle(color: Colors.grey, imagePath: '');
}