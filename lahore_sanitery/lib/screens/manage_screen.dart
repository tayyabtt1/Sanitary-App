import 'dart:io';
import 'package:flutter/material.dart';
import '../services/product_repository.dart';
import '../models/product.dart';
import 'add_edit_product_screen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _products = ProductRepository().getAll();
    });
  }

  Future<void> _openAddEdit({Product? product}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(existingProduct: product),
      ),
    );
    // AddEditProductScreen pops with `true` after a successful
    // save/delete, so we know to refresh the list here.
    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      body: _products.isEmpty
          ? const Center(
              child: Text(
                'No products yet.\nTap + to add your first product.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = _products[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildThumbnail(product.imagePath),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rs. ${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _openAddEdit(product: product),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _openAddEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildThumbnail(String imagePath) {
    if (imagePath.isEmpty) return _brokenImagePlaceholder();

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: 48,
        width: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _brokenImagePlaceholder(),
      );
    }

    return Image.file(
      File(imagePath),
      height: 48,
      width: 48,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _brokenImagePlaceholder(),
    );
  }

  Widget _brokenImagePlaceholder() {
    return Container(
      height: 48,
      width: 48,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 20),
    );
  }
}