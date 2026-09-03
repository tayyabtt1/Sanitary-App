import 'package:hive/hive.dart';

/// Core product model for the Sanitary Store app.
///
/// typeId 0 is reserved for this class in Hive.
class Product {
  String id;
  String name;
  String category;
  double price;
  String imagePath;
  List<String> aliases;

  /// When this product's price was last confirmed/set. Refreshes
  /// every time the product is saved (both on creation and on edit),
  /// so it acts as a "how recent is this price" reminder for the
  /// shop owner — not just a one-time creation date.
  DateTime lastUpdated;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
    List<String>? aliases,
    DateTime? lastUpdated,
  })  : aliases = aliases ?? [],
        lastUpdated = lastUpdated ?? DateTime.now();
}

/// Manual TypeAdapter — no build_runner needed.
///
/// Field 6 (lastUpdated) was added after products with fields 0-5
/// only were already saved on real devices. read() handles that by
/// falling back to DateTime.now() when field 6 isn't present in the
/// stored data, so existing saved products don't crash on load —
/// they just get "now" as their last-updated date the first time
/// they're read after this update.
class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      price: fields[3] as double,
      imagePath: fields[4] as String,
      aliases: (fields[5] as List).cast<String>(),
      lastUpdated:
          fields.containsKey(6) ? fields[6] as DateTime : DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(7) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.aliases)
      ..writeByte(6)
      ..write(obj.lastUpdated);
  }
}