import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../services/inventory_service.dart';
import '../utils/validators.dart';

class StockEntryForm extends StatefulWidget {
  final VoidCallback? onSaveSuccess;

  const StockEntryForm({super.key, this.onSaveSuccess});

  @override
  State<StockEntryForm> createState() => _StockEntryFormState();
}

class _StockEntryFormState extends State<StockEntryForm> {
  final _formKey = GlobalKey<FormState>();

  final _skuController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _reorderLevelController = TextEditingController();

  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void dispose() {
    _skuController.dispose();
    _itemNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _skuController.clear();
    _itemNameController.clear();
    _quantityController.clear();
    _unitPriceController.clear();
    _reorderLevelController.clear();
    setState(() {
      _selectedCategory = null;
    });
  }

  /// Helper to populate sample data quickly for lab demonstration
  void _populateSampleData(int sampleIndex) {
    if (sampleIndex == 1) {
      _skuController.text = 'STK-101';
      _itemNameController.text = 'USB C Cable';
      _quantityController.text = '4';
      _unitPriceController.text = '19.90';
      _reorderLevelController.text = '5';
      setState(() => _selectedCategory = 'Electronics');
    } else if (sampleIndex == 2) {
      _skuController.text = 'STK-102';
      _itemNameController.text = 'Notebook';
      _quantityController.text = '25';
      _unitPriceController.text = '4.50';
      _reorderLevelController.text = '10';
      setState(() => _selectedCategory = 'Stationery');
    } else if (sampleIndex == 3) {
      _skuController.text = 'STK-103';
      _itemNameController.text = 'Wireless Mouse';
      _quantityController.text = '1';
      _unitPriceController.text = '35.00';
      _reorderLevelController.text = '3';
      setState(() => _selectedCategory = 'Electronics');
    }
  }

  Future<void> _handleSave() async {
    // 1. Task 1: Form Validation Gate
    // GlobalKey<FormState> validates all fields and blocks Firestore write if invalid
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please resolve validation errors before saving.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newItem = StockItem(
      sku: _skuController.text.trim().toUpperCase(),
      itemName: _itemNameController.text.trim(),
      category: _selectedCategory!,
      quantity: int.parse(_quantityController.text.trim()),
      unitPrice: double.parse(_unitPriceController.text.trim()),
      reorderLevel: int.parse(_reorderLevelController.text.trim()),
    );

    try {
      // 2. Task 2: Firestore write to 'stockItems' collection with server timestamp
      await InventoryService().addStockItem(newItem);

      if (!mounted) return;

      // Display confirmation only after acknowledged write
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Item ${newItem.sku} (${newItem.itemName}) saved to Firestore!'),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // On successful save, reset the form
      _resetForm();
      widget.onSaveSuccess?.call();
    } catch (e) {
      if (!mounted) return;

      // Handle write errors without clearing the form (Form inputs remain intact)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save to Firestore: $e\nForm contents have been preserved.'),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with Quick Fill helper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Stock Item Entry',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<int>(
                          icon: const Icon(Icons.flash_on, color: Colors.amber),
                          tooltip: 'Quick-Fill Test Data',
                          onSelected: _populateSampleData,
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 1,
                              child: Text('Fill STK-101 (USB C Cable)'),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Text('Fill STK-102 (Notebook)'),
                            ),
                            PopupMenuItem(
                              value: 3,
                              child: Text('Fill STK-103 (Wireless Mouse)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // 1. SKU Field
                    TextFormField(
                      controller: _skuController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Stock Keeping Unit (SKU) *',
                        hintText: 'e.g. STK-101',
                        prefixIcon: Icon(Icons.qr_code),
                        helperText: 'Format: STK- followed by 3 digits (e.g. STK-101)',
                        border: OutlineInputBorder(),
                      ),
                      validator: StockValidators.validateSku,
                    ),
                    const SizedBox(height: 16),

                    // 2. Item Name Field
                    TextFormField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name *',
                        hintText: 'e.g. Wireless Mouse',
                        prefixIcon: Icon(Icons.label_outline),
                        helperText: 'Trimmed; at least 3 characters',
                        border: OutlineInputBorder(),
                      ),
                      validator: StockValidators.validateItemName,
                    ),
                    const SizedBox(height: 16),

                    // 3. Category Selector Field
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedCategory),
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: kPermittedCategories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                      validator: StockValidators.validateCategory,
                    ),
                    const SizedBox(height: 16),

                    // 4. Quantity Field
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                        hintText: 'e.g. 10',
                        prefixIcon: Icon(Icons.numbers),
                        helperText: 'Whole number, 0 or above',
                        border: OutlineInputBorder(),
                      ),
                      validator: StockValidators.validateQuantity,
                    ),
                    const SizedBox(height: 16),

                    // 5. Unit Price RM Field
                    TextFormField(
                      controller: _unitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Unit Price (RM) *',
                        hintText: 'e.g. 19.90',
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: 'RM ',
                        helperText: 'RM amount greater than 0',
                        border: OutlineInputBorder(),
                      ),
                      validator: StockValidators.validateUnitPrice,
                    ),
                    const SizedBox(height: 16),

                    // 6. Reorder Level Field
                    TextFormField(
                      controller: _reorderLevelController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reorder Level *',
                        hintText: 'e.g. 5',
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                        helperText: 'Whole number, 0 or above',
                        border: OutlineInputBorder(),
                      ),
                      validator: StockValidators.validateReorderLevel,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _isSaving ? null : _handleSave,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _isSaving ? 'Saving to Firestore...' : 'Save Item',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isSaving ? null : _resetForm,
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
