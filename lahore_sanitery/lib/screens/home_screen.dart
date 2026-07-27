import 'package:flutter/material.dart';
import '../services/product_repository.dart';
import '../services/voice_search_service.dart';
import '../widgets/mic_button.dart';
import '../widgets/category_tile.dart';
import '../widgets/voice_search_sheet.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleMicTap(BuildContext context) async {
    final recognizedText = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SizedBox.expand(child: VoiceSearchSheet()),
    );

    if (recognizedText == null || recognizedText.trim().isEmpty) return;
    if (!context.mounted) return;

    final allProducts = ProductRepository().getAll();
    final matches = VoiceSearchService().matchProducts(
      recognizedText,
      allProducts,
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          query: recognizedText,
          results: matches,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ProductRepository().getAllCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lahore Sanitary'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              MicButton(onTap: () => _handleMicTap(context)),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or size...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                // Phase 5: wire onSubmitted -> same matchProducts +
                // SearchResultsScreen flow used above for voice.
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  return CategoryTile(
                    categoryName: categories[index],
                    onTap: () {
                      // Phase 5: navigate to Products screen filtered
                      // by this category.
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}