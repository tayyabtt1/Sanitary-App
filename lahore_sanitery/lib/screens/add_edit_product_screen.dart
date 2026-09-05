import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../services/product_repository.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? existingProduct;

  const AddEditProductScreen({super.key, this.existingProduct});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  String? _selectedCategory;
  String? _pickedImagePath;
  String? _existingImagePath;

  bool get _isEditing => widget.existingProduct != null;

  final List<String> _categories = const [
    'Pipes',
    'Nuts & Bolts',
    'Taps',
    'Fittings',
    'Valves',
    'Tools',
  ];

  @override
  void initState() {
    super.initState();
    final product = widget.existingProduct;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    _selectedCategory = product?.category;
    _existingImagePath = product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Shows a simple choice sheet — Camera or Gallery — instead of
  /// always jumping straight to the gallery. This is what the client
  /// was missing: previously there was no way to take a fresh photo
  /// directly, only pick an existing one.
  Future<void> _showImageSourceOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _pickedImagePath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Could not open camera. Check camera permission in phone settings.'
                  : 'Could not open gallery.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final finalImagePath = _pickedImagePath ?? _existingImagePath ?? '';

    final repository = ProductRepository();
    final product = Product(
      id: widget.existingProduct?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      price: double.parse(_priceController.text.trim()),
      imagePath: finalImagePath,
      aliases: widget.existingProduct?.aliases ?? [],
      lastUpdated: DateTime.now(),
    );

    if (_isEditing) {
      await repository.updateProduct(product);
    } else {
      await repository.addProduct(product);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${widget.existingProduct!.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ProductRepository().deleteProduct(widget.existingProduct!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImagePath != null) {
      return Image.file(File(_pickedImagePath!), fit: BoxFit.cover);
    }
    if (_existingImagePath != null && _existingImagePath!.isNotEmpty) {
      if (_existingImagePath!.startsWith('http')) {
        return Image.network(_existingImagePath!, fit: BoxFit.cover);
      }
      return Image.file(File(_existingImagePath!), fit: BoxFit.cover);
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tap to take or choose a photo',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Product Image',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceOptions,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _buildImagePreview(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Product Name',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Product name is required'
                    : null,
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
              const Text('Category',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
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
              const Text('Price (PKR)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
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
                  onPressed: _saveProduct,
                  child:
                      const Text('Save Product', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}