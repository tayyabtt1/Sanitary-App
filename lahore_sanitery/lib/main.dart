import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/app_config.dart';
import 'services/product_repository.dart';
import 'data/dummy_products.dart';
import 'widgets/main_nav.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Hive (hive_flutter's initFlutter() finds the right storage
  //    directory automatically — no path_provider setup needed)
  await Hive.initFlutter();

  // 2. Register adapter + open the products box
  await ProductRepository.init();

  // 3. Seed dummy data ONLY if the box is empty AND useDummyData is
  //    still true in app_config.dart. Once real products are being
  //    entered by the client, flip that flag to false.
  if (AppConfig.useDummyData) {
    await ProductRepository().seedIfEmpty(dummyProducts);
  }

  runApp(const SanitaryStoreApp());
}

class SanitaryStoreApp extends StatelessWidget {
  const SanitaryStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds MaterialApp whenever themeNotifier's value changes,
    // e.g. when ThemeToggleButton is tapped anywhere in the app.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Lahore Sanitary',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const MainNav(),
        );
      },
    );
  }
}