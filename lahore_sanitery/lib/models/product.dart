import 'package:hive/hive.dart';

/// Core product model for the Sanitary Store app.
///
/// typeId 0 is reserved for this class in Hive. If you add more Hive
/// models later, give each a unique typeId (1, 2, 3...) — never reuse one.
class Product {
  String id; // unique id, e.g. uuid string
  String name; // e.g. "1/2 inch PVC Pipe"
  String category; // e.g. "Pipes", "Nuts & Bolts", "Taps"
  double price;
  String imagePath; // local file path to the product photo
  List<String> aliases; // alternate spoken phrasings for voice search
  // e.g. ["adha inch pipe", "half inch pipe", "aadha inch"]

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imagePath,
    List<String>? aliases,
  }) : aliases = aliases ?? [];
}

/// Manual TypeAdapter — no build_runner needed.
///
/// Field order below (0,1,2,3,4,5) must stay consistent once you start
/// saving real data. If you add a new field later, give it the NEXT
/// unused number — never renumber existing fields, or old saved data
/// will read back wrong.
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
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(6) // number of fields
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
      ..write(obj.aliases);
  }
}