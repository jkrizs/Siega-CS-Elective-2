import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/product.dart';
import '../../providers/app_providers.dart';
import '../../utils/error_messages.dart';
import '../../widgets/category_name_dialog.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? productToEdit;

  const ProductFormScreen({super.key, this.productToEdit});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  String? _currentImageUrl;
  Uint8List? _pickedBytes;
  String? _pickedName;
  String? _pickedType;
  String? _imageError;
  final List<ProductColorOption> _selectedColors = [];
  String? _colorError;
  int? _selectedCategoryId;
  bool _isSaving = false;

  bool _addingCategory = false;

  bool get isEditing => widget.productToEdit != null;

  Future<void> _addCategory() async {
    final products = ref.read(productsProvider);
    final name = await showCategoryNameDialog(
      context,
      title: 'Add category',
      existingNames:
          products.categories.map((c) => c.name.toLowerCase()).toSet(),
    );
    if (name == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _addingCategory = true);
    try {
      final created = await products.addCategory(name);
      if (mounted) setState(() => _selectedCategoryId = created.id);
      messenger.showSnackBar(
        SnackBar(content: Text('Added category "${created.name}".')),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(error))));
    } finally {
      if (mounted) setState(() => _addingCategory = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(2) : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '10',
    );
    if (p != null && p.imageUrl.isNotEmpty) {
      _currentImageUrl = p.imageUrl;
    } else if (p != null && p.colors.isNotEmpty && p.colors.first.imageUrl.isNotEmpty) {
      _currentImageUrl = p.colors.first.imageUrl;
    }
    _selectedCategoryId = p?.categoryId;
    if (p != null) {
      _selectedColors.addAll(p.colors.where((c) => c.name != 'Default'));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1400,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedBytes = bytes;
        _pickedName = file.name;
        _pickedType = file.mimeType ?? _guessType(file.name);
        _imageError = null;
      });
    } catch (error) {
      debugPrint('Image picker error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the file picker: $error')),
        );
      }
    }
  }

  static String _guessType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final hasImage = _pickedBytes != null || _currentImageUrl != null;
    final hasColor = _selectedColors.isNotEmpty;
    setState(() {
      _imageError = hasImage ? null : 'Choose an image file';
      _colorError = hasColor ? null : 'Pick at least one color';
    });
    if (!formValid || !hasImage || !hasColor) return;

    final products = ref.read(productsProvider);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.parse(_priceController.text.replaceAll(',', '').trim());
      final stock = int.parse(_stockController.text.trim());
      var imageUrl = _currentImageUrl ?? '';
      final bytes = _pickedBytes;
      if (bytes != null) {
        imageUrl = await products.uploadProductImage(
          bytes: bytes,
          fileName: _pickedName ?? 'product.jpg',
          contentType: _pickedType,
        );
      }
      final colors = _selectedColors.map((c) => c.toJson()).toList();
      final categoryId = _selectedCategoryId ??
          (products.categories.isNotEmpty ? products.categories.first.id : 1);

      if (isEditing) {
        await products.updateProduct(
          widget.productToEdit!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          categoryId: categoryId,
          imageUrl: imageUrl,
          colors: colors,
        );
        messenger.showSnackBar(
          SnackBar(content: Text('Updated "$name" successfully!')),
        );
      } else {
        await products.addProduct(
          name: name,
          description: description,
          price: price,
          stock: stock,
          categoryId: categoryId,
          imageUrl: imageUrl,
          colors: colors,
        );
        messenger.showSnackBar(
          SnackBar(content: Text('Added "$name" to store!')),
        );
      }

      router.go('/');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not save product: ${friendlyError(e)}')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final categories = products.categories;

    // Set default category if not set
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name *',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price (\$) *',
                            prefixText: '\$ ',
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Price is required';
                            }
                            final num = double.tryParse(val.trim());
                            if (num == null) return 'Enter a valid number';
                            if (num < 0) return 'Must be 0 or more';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stock Quantity *',
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Stock is required';
                            }
                            final num = int.tryParse(val.trim());
                            if (num == null) return 'Whole number required';
                            if (num < 0) return 'Must be 0 or more';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          key: ValueKey(
                            '$_selectedCategoryId-${categories.length}',
                          ),
                          initialValue: categories
                                  .any((c) => c.id == _selectedCategoryId)
                              ? _selectedCategoryId
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem<int>(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategoryId = val),
                          validator: (val) =>
                              val == null ? 'Select a category' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _isSaving || _addingCategory
                              ? null
                              : _addCategory,
                          icon: _addingCategory
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add),
                          label: const Text('New'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildColorPicker(context),
                  const SizedBox(height: 16),
                  _buildImagePicker(context),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEditing ? 'SAVE CHANGES' : 'CREATE PRODUCT'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isColorSelected(ProductColorOption option) => _selectedColors
      .any((c) => c.name.toLowerCase() == option.name.toLowerCase());

  void _toggleColor(ProductColorOption option) {
    setState(() {
      if (_isColorSelected(option)) {
        _selectedColors.removeWhere(
          (c) => c.name.toLowerCase() == option.name.toLowerCase(),
        );
      } else {
        _selectedColors.add(option);
      }
      if (_selectedColors.isNotEmpty) _colorError = null;
    });
  }

  Widget _buildColorPicker(BuildContext context) {
    final theme = Theme.of(context);
    final options = [
      ...ProductColorOption.palette,
      ..._selectedColors.where(
        (c) => !ProductColorOption.palette.any(
          (p) => p.name.toLowerCase() == c.name.toLowerCase(),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Colors *',
          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          _selectedColors.isEmpty
              ? 'Choose the colors customers can pick from'
              : 'Selected: ${_selectedColors.map((c) => c.name).join(', ')}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              FilterChip(
                avatar: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: option.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                label: Text(option.name),
                selected: _isColorSelected(option),
                onSelected: _isSaving ? null : (_) => _toggleColor(option),
              ),
          ],
        ),
        if (_colorError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              _colorError!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    final theme = Theme.of(context);
    final picked = _pickedBytes;
    final current = _currentImageUrl;

    Widget preview;
    if (picked != null) {
      preview = Image.memory(picked, fit: BoxFit.contain);
    } else if (current != null && current.startsWith('assets/')) {
      preview = Image.asset(
        current,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 48),
      );
    } else if (current != null) {
      preview = Image.network(
        current,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 48),
      );
    } else {
      preview = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          const Text('No image selected'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Product Image *',
          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSaving ? null : _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _imageError != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
            ),
            child: Center(child: preview),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickImage,
              icon: const Icon(Icons.upload_file),
              label: Text(
                picked != null || current != null
                    ? 'Change Image'
                    : 'Choose Image File',
              ),
            ),
            const SizedBox(width: 12),
            if (_pickedName != null)
              Expanded(
                child: Text(
                  _pickedName!,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
        if (_imageError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              _imageError!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
