import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../services/inventory_service.dart';
import '../utils/inventory_filter.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchKeyword = '';
  String _selectedCategory = 'All';
  bool _lowStockOnly = false;
  QuantitySortOrder _sortOrder = QuantitySortOrder.none;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchKeyword = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchKeyword = '';
      _selectedCategory = 'All';
      _lowStockOnly = false;
      _sortOrder = QuantitySortOrder.none;
    });
  }

  bool get _hasActiveFilters =>
      _searchKeyword.isNotEmpty ||
      _selectedCategory != 'All' ||
      _lowStockOnly ||
      _sortOrder != QuantitySortOrder.none;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Top Card: Advanced Search & Filter Controls (Task 3)
        Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row 1: Keyword Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Item Name or SKU (e.g. "mouse", "STK-102")...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchKeyword.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Row 2: Category Filter & Sort Order
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Category Dropdown
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Category: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<String>(
                          value: _selectedCategory,
                          underline: Container(height: 1, color: theme.colorScheme.primary),
                          items: ['All', ...kPermittedCategories].map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                      ],
                    ),

                    // Quantity Sort Order Dropdown
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Sort Qty: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        DropdownButton<QuantitySortOrder>(
                          value: _sortOrder,
                          underline: Container(height: 1, color: theme.colorScheme.primary),
                          items: const [
                            DropdownMenuItem(
                              value: QuantitySortOrder.none,
                              child: Text('Default (None)'),
                            ),
                            DropdownMenuItem(
                              value: QuantitySortOrder.ascending,
                              child: Text('Low to High (Asc) ↑'),
                            ),
                            DropdownMenuItem(
                              value: QuantitySortOrder.descending,
                              child: Text('High to Low (Desc) ↓'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _sortOrder = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Row 3: Low-Stock Filter Switch & Clear Filters Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Low Stock Toggle (quantity <= reorderLevel)
                    FilterChip(
                      selected: _lowStockOnly,
                      avatar: Icon(
                        _lowStockOnly ? Icons.warning : Icons.warning_amber_outlined,
                        size: 18,
                        color: _lowStockOnly ? Colors.white : Colors.orange,
                      ),
                      label: const Text('Low Stock Only (Qty \u2264 Reorder)'),
                      selectedColor: Colors.deepOrange,
                      labelStyle: TextStyle(
                        color: _lowStockOnly ? Colors.white : theme.textTheme.bodyMedium?.color,
                        fontWeight: _lowStockOnly ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() => _lowStockOnly = selected);
                      },
                    ),

                    // Clear Filters Button
                    TextButton.icon(
                      onPressed: _hasActiveFilters ? _clearAllFilters : null,
                      icon: const Icon(Icons.filter_alt_off),
                      label: const Text('Clear Filters'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Firestore Inventory List View (Task 2, Task 3 & Task 5)
        Expanded(
          child: StreamBuilder<List<StockItem>>(
            stream: InventoryService().getStockItemsStream(),
            builder: (context, snapshot) {
              // 1. Loading State
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Retrieving stock items from Cloud Firestore...'),
                    ],
                  ),
                );
              }

              // 2. Error State
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        const Text(
                          'Firestore Connection Issue',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Connection'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final allItems = snapshot.data ?? [];

              // 3. Empty Database State
              if (allItems.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'No Inventory Records in Firestore',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Save items using the Add Stock tab or seed acceptance test items.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await InventoryService().seedAcceptanceData();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Seeded STK-101, STK-102, STK-103 into Firestore!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Seed failed: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Seed Test Data (STK-101, 102, 103)'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Apply Task 3 Combined Filtering & Sorting
              final visibleItems = InventoryFilterHelper.filterAndSort(
                items: allItems,
                keyword: _searchKeyword,
                category: _selectedCategory,
                lowStockOnly: _lowStockOnly,
                sortOrder: _sortOrder,
              );

              // 4. No-results State (Filter returned 0 items)
              if (visibleItems.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.amber.shade700),
                        const SizedBox(height: 16),
                        const Text(
                          'No Matching Items Found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No stock items match your current filter and search criteria.\n'
                          'Try clearing filters or refining your keyword.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _clearAllFilters,
                          icon: const Icon(Icons.filter_alt_off),
                          label: const Text('Clear All Filters'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 5. Normal Display: List of Stock Item Cards
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: visibleItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = visibleItems[index];
                  final isLow = item.isLowStock;

                  return Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isLow ? Colors.red.shade300 : Colors.grey.shade300,
                        width: isLow ? 1.5 : 0.8,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: SKU, Category Badge & Low Stock Warning
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.sku,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (isLow)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.red.shade400),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.warning, size: 14, color: Colors.red.shade800),
                                      const SizedBox(width: 4),
                                      Text(
                                        'LOW STOCK',
                                        style: TextStyle(
                                          color: Colors.red.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Item Name
                          Text(
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Details Row: Quantity, Unit Price, Reorder Level
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricItem(
                                label: 'Quantity',
                                value: '${item.quantity}',
                                isAlert: isLow,
                              ),
                              _buildMetricItem(
                                label: 'Reorder Level',
                                value: '${item.reorderLevel}',
                              ),
                              _buildMetricItem(
                                label: 'Unit Price',
                                value: 'RM ${item.unitPrice.toStringAsFixed(2)}',
                                isHighlight: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    bool isAlert = false,
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isAlert
                ? Colors.red.shade800
                : isHighlight
                    ? Colors.green.shade800
                    : Colors.black87,
          ),
        ),
      ],
    );
  }
}
