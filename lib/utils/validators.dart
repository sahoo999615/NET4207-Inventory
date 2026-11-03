import '../models/stock_item.dart';

/// Form validation utility class for the Stock Inventory Manager
class StockValidators {
  /// Validates SKU format: Must be 'STK-' followed by exactly 3 digits (e.g., STK-101)
  static String? validateSku(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'SKU is required';
    }
    final regex = RegExp(r'^STK-\d{3}$');
    if (!regex.hasMatch(trimmed)) {
      return 'SKU must be in format STK- followed by 3 digits (e.g. STK-101)';
    }
    return null;
  }

  /// Validates Item Name: Trimmed; must be at least 3 characters
  static String? validateItemName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Item name is required';
    }
    if (trimmed.length < 3) {
      return 'Item name must be at least 3 characters';
    }
    return null;
  }

  /// Validates Category: Compulsory, must be one of the permitted categories
  static String? validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a category';
    }
    if (!kPermittedCategories.contains(value.trim())) {
      return 'Category must be Electronics, Stationery, Hardware or Grocery';
    }
    return null;
  }

  /// Validates Quantity: Compulsory, non-negative whole integer (0 or above)
  static String? validateQuantity(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Quantity is required';
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Quantity must be a whole number, 0 or above';
    }
    return null;
  }

  /// Validates Unit Price: Compulsory, positive number (> 0)
  static String? validateUnitPrice(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Unit price is required';
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 'Unit price must be an amount greater than RM 0';
    }
    return null;
  }

  /// Validates Reorder Level: Compulsory, non-negative whole integer (0 or above)
  static String? validateReorderLevel(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Reorder level is required';
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Reorder level must be a whole number, 0 or above';
    }
    return null;
  }
}
