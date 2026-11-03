import 'package:flutter_test/flutter_test.dart';
import 'package:stock_inventory_app/models/stock_item.dart';
import 'package:stock_inventory_app/utils/validators.dart';
import 'package:stock_inventory_app/utils/inventory_filter.dart';

void main() {
  group('Task 1: Form Validation Rules (10 Marks)', () {
    test('SKU Validation - STK- followed by 3 digits', () {
      expect(StockValidators.validateSku(null), 'SKU is required');
      expect(StockValidators.validateSku(''), 'SKU is required');
      expect(StockValidators.validateSku('   '), 'SKU is required');
      expect(StockValidators.validateSku('STK-1'),
          'SKU must be in format STK- followed by 3 digits (e.g. STK-101)');
      expect(StockValidators.validateSku('STK-1234'),
          'SKU must be in format STK- followed by 3 digits (e.g. STK-101)');
      expect(StockValidators.validateSku('ITEM-101'),
          'SKU must be in format STK- followed by 3 digits (e.g. STK-101)');
      expect(StockValidators.validateSku('stk-101'),
          'SKU must be in format STK- followed by 3 digits (e.g. STK-101)');

      // Valid SKUs
      expect(StockValidators.validateSku('STK-101'), isNull);
      expect(StockValidators.validateSku('STK-102'), isNull);
      expect(StockValidators.validateSku('STK-103'), isNull);
    });

    test('Item Name Validation - Trimmed at least 3 characters', () {
      expect(StockValidators.validateItemName(null), 'Item name is required');
      expect(StockValidators.validateItemName(''), 'Item name is required');
      expect(StockValidators.validateItemName('  '), 'Item name is required');
      expect(StockValidators.validateItemName('ab'), 'Item name must be at least 3 characters');
      expect(StockValidators.validateItemName('  ab  '), 'Item name must be at least 3 characters');

      // Valid names
      expect(StockValidators.validateItemName('USB C Cable'), isNull);
      expect(StockValidators.validateItemName('Notebook'), isNull);
      expect(StockValidators.validateItemName('Wireless Mouse'), isNull);
    });

    test('Category Validation - Must be one of the 4 permitted categories', () {
      expect(StockValidators.validateCategory(null), 'Please select a category');
      expect(StockValidators.validateCategory(''), 'Please select a category');
      expect(StockValidators.validateCategory('Furniture'),
          'Category must be Electronics, Stationery, Hardware or Grocery');

      // Valid categories
      expect(StockValidators.validateCategory('Electronics'), isNull);
      expect(StockValidators.validateCategory('Stationery'), isNull);
      expect(StockValidators.validateCategory('Hardware'), isNull);
      expect(StockValidators.validateCategory('Grocery'), isNull);
    });

    test('Quantity Validation - Non-negative whole integer', () {
      expect(StockValidators.validateQuantity(null), 'Quantity is required');
      expect(StockValidators.validateQuantity(''), 'Quantity is required');
      expect(StockValidators.validateQuantity('-1'),
          'Quantity must be a whole number, 0 or above');
      expect(StockValidators.validateQuantity('4.5'),
          'Quantity must be a whole number, 0 or above');
      expect(StockValidators.validateQuantity('abc'),
          'Quantity must be a whole number, 0 or above');

      // Valid quantities
      expect(StockValidators.validateQuantity('0'), isNull);
      expect(StockValidators.validateQuantity('4'), isNull);
      expect(StockValidators.validateQuantity('25'), isNull);
    });

    test('Unit Price Validation - Amount greater than RM 0', () {
      expect(StockValidators.validateUnitPrice(null), 'Unit price is required');
      expect(StockValidators.validateUnitPrice(''), 'Unit price is required');
      expect(StockValidators.validateUnitPrice('0'),
          'Unit price must be an amount greater than RM 0');
      expect(StockValidators.validateUnitPrice('0.00'),
          'Unit price must be an amount greater than RM 0');
      expect(StockValidators.validateUnitPrice('-10.50'),
          'Unit price must be an amount greater than RM 0');
      expect(StockValidators.validateUnitPrice('abc'),
          'Unit price must be an amount greater than RM 0');

      // Valid unit prices
      expect(StockValidators.validateUnitPrice('19.90'), isNull);
      expect(StockValidators.validateUnitPrice('4.50'), isNull);
      expect(StockValidators.validateUnitPrice('35.00'), isNull);
    });

    test('Reorder Level Validation - Non-negative whole integer', () {
      expect(StockValidators.validateReorderLevel(null), 'Reorder level is required');
      expect(StockValidators.validateReorderLevel(''), 'Reorder level is required');
      expect(StockValidators.validateReorderLevel('-1'),
          'Reorder level must be a whole number, 0 or above');
      expect(StockValidators.validateReorderLevel('3.2'),
          'Reorder level must be a whole number, 0 or above');

      // Valid reorder levels
      expect(StockValidators.validateReorderLevel('0'), isNull);
      expect(StockValidators.validateReorderLevel('5'), isNull);
      expect(StockValidators.validateReorderLevel('10'), isNull);
    });
  });

  group('Task 3: Advanced Search and Filtering Acceptance Tests (8 Marks)', () {
    final sampleItems = [
      const StockItem(
        id: '1',
        sku: 'STK-101',
        itemName: 'USB C Cable',
        category: 'Electronics',
        quantity: 4,
        unitPrice: 19.90,
        reorderLevel: 5,
      ),
      const StockItem(
        id: '2',
        sku: 'STK-102',
        itemName: 'Notebook',
        category: 'Stationery',
        quantity: 25,
        unitPrice: 4.50,
        reorderLevel: 10,
      ),
      const StockItem(
        id: '3',
        sku: 'STK-103',
        itemName: 'Wireless Mouse',
        category: 'Electronics',
        quantity: 1,
        unitPrice: 35.00,
        reorderLevel: 3,
      ),
    ];

    test('Low Stock Flag computation: quantity <= reorderLevel', () {
      // STK-101: 4 <= 5 -> True (Low Stock)
      expect(sampleItems[0].isLowStock, isTrue);
      // STK-102: 25 <= 10 -> False (Normal)
      expect(sampleItems[1].isLowStock, isFalse);
      // STK-103: 1 <= 3 -> True (Low Stock)
      expect(sampleItems[2].isLowStock, isTrue);
    });

    test('Required Test Outcome 1: Search "mouse" with Electronics and Low stock -> Only STK-103 appears', () {
      final results = InventoryFilterHelper.filterAndSort(
        items: sampleItems,
        keyword: 'mouse',
        category: 'Electronics',
        lowStockOnly: true,
        sortOrder: QuantitySortOrder.none,
      );

      expect(results.length, 1);
      expect(results.first.sku, 'STK-103');
      expect(results.first.itemName, 'Wireless Mouse');
    });

    test('Required Test Outcome 2: Search "STK-102" with All / all-stock -> Notebook appears (case-insensitive partial)', () {
      // Test lowercase keyword 'stk-102'
      final resultsLower = InventoryFilterHelper.filterAndSort(
        items: sampleItems,
        keyword: 'stk-102',
        category: 'All',
        lowStockOnly: false,
        sortOrder: QuantitySortOrder.none,
      );

      expect(resultsLower.length, 1);
      expect(resultsLower.first.sku, 'STK-102');
      expect(resultsLower.first.itemName, 'Notebook');

      // Test partial keyword '102'
      final resultsPartial = InventoryFilterHelper.filterAndSort(
        items: sampleItems,
        keyword: '102',
        category: 'All',
        lowStockOnly: false,
        sortOrder: QuantitySortOrder.none,
      );

      expect(resultsPartial.length, 1);
      expect(resultsPartial.first.sku, 'STK-102');
    });

    test('Required Test Outcome 3: Sort all by quantity ascending -> STK-103 (1), STK-101 (4), STK-102 (25)', () {
      final results = InventoryFilterHelper.filterAndSort(
        items: sampleItems,
        keyword: '',
        category: 'All',
        lowStockOnly: false,
        sortOrder: QuantitySortOrder.ascending,
      );

      expect(results.length, 3);
      expect(results[0].sku, 'STK-103'); // qty 1
      expect(results[1].sku, 'STK-101'); // qty 4
      expect(results[2].sku, 'STK-102'); // qty 25
    });

    test('Sort all by quantity descending -> STK-102 (25), STK-101 (4), STK-103 (1)', () {
      final results = InventoryFilterHelper.filterAndSort(
        items: sampleItems,
        keyword: '',
        category: 'All',
        lowStockOnly: false,
        sortOrder: QuantitySortOrder.descending,
      );

      expect(results.length, 3);
      expect(results[0].sku, 'STK-102'); // qty 25
      expect(results[1].sku, 'STK-101'); // qty 4
      expect(results[2].sku, 'STK-103'); // qty 1
    });

    test('Required Test Outcome 4: Clear all filters -> Full list of 3 items appears again', () {
      // Step A: Apply combined restrictive filter (0 matches)
      final zeroResults = InventoryFilterHelper.filterAndSort(
        items: sampleItems,
        keyword: 'non-existent-keyword',
        category: 'Hardware',
        lowStockOnly: true,
        sortOrder: QuantitySortOrder.none,
      );
      expect(zeroResults, isEmpty);

      // Step B: Clear all filters
      final resetResults = InventoryFilterHelper.filterAndSort(
        items: sampleItems,
        keyword: '',
        category: 'All',
        lowStockOnly: false,
        sortOrder: QuantitySortOrder.none,
      );
      expect(resetResults.length, 3);
    });
  });
}
