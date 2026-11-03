import '../models/stock_item.dart';

enum QuantitySortOrder {
  none,
  ascending,
  descending,
}

class InventoryFilterHelper {
  /// Filters a list of StockItem objects based on:
  /// - [keyword]: partial, case-insensitive match on itemName OR sku
  /// - [category]: 'All' or specific permitted category
  /// - [lowStockOnly]: only items where quantity <= reorderLevel
  /// - [sortOrder]: quantity ascending, descending, or none
  static List<StockItem> filterAndSort({
    required List<StockItem> items,
    required String keyword,
    required String category,
    required bool lowStockOnly,
    required QuantitySortOrder sortOrder,
  }) {
    final query = keyword.trim().toLowerCase();

    // 1. Filter with logical AND across active criteria
    final filtered = items.where((item) {
      // Keyword match (partial, case-insensitive against itemName OR sku)
      final matchesKeyword = query.isEmpty ||
          item.itemName.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      // Category match ('All' matches any category)
      final matchesCategory =
          (category == 'All') || (item.category.toLowerCase() == category.toLowerCase());

      // Low-stock match (quantity <= reorderLevel)
      final matchesLowStock = !lowStockOnly || (item.quantity <= item.reorderLevel);

      return matchesKeyword && matchesCategory && matchesLowStock;
    }).toList();

    // 2. Sort by quantity if requested
    if (sortOrder == QuantitySortOrder.ascending) {
      filtered.sort((a, b) => a.quantity.compareTo(b.quantity));
    } else if (sortOrder == QuantitySortOrder.descending) {
      filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
    }

    return filtered;
  }
}
