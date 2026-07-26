import '../models/product.dart';

/// Dummy data for Phase 1-2 development, so you can build and preview
/// screens before real product photos/prices from the client exist.
///
/// imagePath here uses network placeholder URLs (picsum.photos) just so
/// something renders — swap these for real local file paths (from image
/// picker / camera) once you're doing real product entry in Phase 3.
final List<Product> dummyProducts = [
  Product(
    id: '1',
    name: '1/2 inch PVC Pipe',
    category: 'Pipes',
    price: 250,
    imagePath: 'https://picsum.photos/seed/pipe1/300/300',
    aliases: ['adha inch pipe', 'half inch pipe', 'aadha inch'],
  ),
  Product(
    id: '2',
    name: 'HDPE Pressure Pipe',
    category: 'Pipes',
    price: 12.50,
    imagePath: 'https://picsum.photos/seed/pipe2/300/300',
    aliases: ['pressure pipe', 'hdpe'],
  ),
  Product(
    id: '3',
    name: 'Stainless Steel Bolt Set',
    category: 'Nuts & Bolts',
    price: 8.99,
    imagePath: 'https://picsum.photos/seed/bolt1/300/300',
    aliases: ['steel bolt', 'bolt set'],
  ),
  Product(
    id: '4',
    name: 'Brass Ball Valve',
    category: 'Valves',
    price: 32.00,
    imagePath: 'https://picsum.photos/seed/valve1/300/300',
    aliases: ['ball valve', 'brass valve'],
  ),
  Product(
    id: '5',
    name: 'Chrome Mixer Tap',
    category: 'Taps',
    price: 45.00,
    imagePath: 'https://picsum.photos/seed/tap1/300/300',
    aliases: ['mixer tap', 'chrome tap'],
  ),
  Product(
    id: '6',
    name: 'Ceramic Basin',
    category: 'Fittings',
    price: 120.00,
    imagePath: 'https://picsum.photos/seed/basin1/300/300',
    aliases: ['basin', 'ceramic sink'],
  ),
  Product(
    id: '7',
    name: 'Galvanized Clamp',
    category: 'Fittings',
    price: 5.40,
    imagePath: 'https://picsum.photos/seed/clamp1/300/300',
    aliases: ['clamp', 'pipe clamp'],
  ),
  Product(
    id: '8',
    name: 'Textured Ceramic Wall Tile',
    category: 'Tools',
    price: 450.00,
    imagePath: 'https://picsum.photos/seed/tile1/300/300',
    aliases: ['wall tile', 'ceramic tile'],
  ),
];