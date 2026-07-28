import 'package:flutter/material.dart';
import '../services/product_repository.dart';
import '../services/voice_search_service.dart';
import '../widgets/mic_button.dart';
import '../widgets/category_tile.dart';
import '../widgets/voice_search_sheet.dart';
import 'search_results_screen.dart';
import 'products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Reused for both voice and typed search, so matching behaves
  // identically regardless of input method.
  final VoiceSearchService _searchMatcher = VoiceSearchService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToResults(String query) {
    if (query.trim().isEmpty) return;

    final allProducts = ProductRepository().getAll();
    final matches = _searchMatcher.matchProducts(query, allProducts);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(query: query, results: matches),
      ),
    );
  }

  Future<void> _handleMicTap() async {
    final recognizedText = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SizedBox.expand(child: VoiceSearchSheet()),
    );

    if (recognizedText == null || recognizedText.trim().isEmpty) return;
    if (!mounted) return;

    _goToResults(recognizedText);
  }

  void _openCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsScreen(initialCategory: category),
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
              MicButton(onTap: _handleMicTap),
              const SizedBox(height: 24),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _goToResults,
                decoration: InputDecoration(
                  hintText: 'Search by name or size...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _goToResults(_searchController.text),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                    onTap: () => _openCategory(categories[index]),
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