import 'package:flutter/material.dart';
import '../services/product_repository.dart';
import '../widgets/product_card.dart';
import '../widgets/theme_toggle_button.dart';

class ProductsScreen extends StatefulWidget {
  /// Optional category to pre-select, e.g. when navigating here from
  /// tapping a category tile on the Home screen. Defaults to 'All'.
  final String? initialCategory;

  const ProductsScreen({super.key, this.initialCategory});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final repo = ProductRepository();
    final categories = ['All', ...repo.getAllCategories()];
    final products = _selectedCategory == 'All'
        ? repo.getAll()
        : repo.getByCategory(_selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lahore Sanitary'),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectedCategory == 'All'
                      ? 'Featured Products'
                      : _selectedCategory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text(
                        'No products in this category yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(product: products[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}