import 'package:hive/hive.dart';
import '../models/product.dart';

/// Handles all reads/writes to the local Hive database.
/// Keep all Hive-specific code here — screens should never talk to
/// Hive directly, only through this repository. Makes it easy to swap
/// storage later (e.g. to Firebase) without touching UI code.
class ProductRepository {
  static const String boxName = 'products';

  Box<Product> get _box => Hive.box<Product>(boxName);

  /// Call once at app startup, before runApp().
  static Future<void> init() async {
    Hive.registerAdapter(ProductAdapter());
    await Hive.openBox<Product>(boxName);
  }

  List<Product> getAll() {
    return _box.values.toList();
  }

  List<Product> getByCategory(String category) {
    return _box.values.where((p) => p.category == category).toList();
  }

  List<String> getAllCategories() {
    return _box.values.map((p) => p.category).toSet().toList();
  }

  Future<void> addProduct(Product product) async {
    await _box.put(product.id, product);
  }

  Future<void> updateProduct(Product product) async {
    await _box.put(product.id, product); // put() overwrites if id exists
  }

  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
  }

  Product? getById(String id) {
    return _box.get(id);
  }

  int get productCount => _box.length;

  /// Wipes all products. Useful during development, don't wire this
  /// to any UI button in the shipped app.
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Seeds the box with dummy data — only if it's currently empty.
  /// Safe to call every app startup during Phase 1-2 development.
  Future<void> seedIfEmpty(List<Product> dummyData) async {
    if (_box.isEmpty) {
      for (final product in dummyData) {
        await _box.put(product.id, product);
      }
    }
  }
}