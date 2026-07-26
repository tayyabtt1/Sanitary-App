import 'package:flutter/material.dart';
import '../models/product.dart';

class AddEditProductScreen extends StatelessWidget {
  final Product? existingProduct;

  const AddEditProductScreen({super.key, this.existingProduct});

  @override
  Widget build(BuildContext context) {
    final isEditing = existingProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Product Image', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 32, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Tap to add photo', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              // Phase 3: wrap in GestureDetector -> image_picker
            ),
            const SizedBox(height: 20),
            const Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: existingProduct?.name ?? ''),
              decoration: InputDecoration(
                hintText: 'Enter product title',
                suffixIcon: const Icon(Icons.mic, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: existingProduct?.category,
              items: const [
                'Pipes', 'Nuts & Bolts', 'Taps', 'Fittings', 'Valves', 'Tools'
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (_) {}, // Phase 3: wire to form state
              decoration: InputDecoration(
                hintText: 'Select category',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Price (PKR)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(
                text: existingProduct?.price.toStringAsFixed(2) ?? '',
              ),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Rs. 0.00',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Phase 3: save to ProductRepository, then pop
                },
                child: const Text('Save Product', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}