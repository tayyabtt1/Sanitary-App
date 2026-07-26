import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/product_repository.dart';
import 'data/dummy_products.dart';
import 'widgets/main_nav.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Hive (hive_flutter's initFlutter() finds the right storage
  //    directory automatically — no path_provider setup needed)
  await Hive.initFlutter();

  // 2. Register adapter + open the products box
  await ProductRepository.init();

  // 3. Seed dummy data ONLY if the box is empty (safe on every restart)
  await ProductRepository().seedIfEmpty(dummyProducts);

  runApp(const SanitaryStoreApp());
}

class SanitaryStoreApp extends StatelessWidget {
  const SanitaryStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lahore Sanitary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainNav(), // bottom-nav shell wiring Home/Products/Manage
    );
  }
}