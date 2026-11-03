import 'package:cloud_firestore/cloud_firestore.dart';

/// Permitted categories per specification
const List<String> kPermittedCategories = [
  'Electronics',
  'Stationery',
  'Hardware',
  'Grocery',
];

/// Data model representing a stock inventory item stored in Firestore
class StockItem {
  final String id;
  final String sku;
  final String itemName;
  final String category;
  final int quantity;
  final double unitPrice;
  final int reorderLevel;
  final DateTime? createdAt;

  const StockItem({
    this.id = '',
    required this.sku,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.reorderLevel,
    this.createdAt,
  });

  /// Check whether current stock is at or below the reorder threshold
  bool get isLowStock => quantity <= reorderLevel;

  /// Convert model instance to a Firestore document map
  Map<String, dynamic> toFirestoreMap() {
    return {
      'sku': sku.trim().toUpperCase(),
      'itemName': itemName.trim(),
      'category': category.trim(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'reorderLevel': reorderLevel,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a StockItem from a Firestore DocumentSnapshot
  factory StockItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StockItem.fromMap(data, doc.id);
  }

  /// Create a StockItem from a generic Map and document ID
  factory StockItem.fromMap(Map<String, dynamic> data, [String id = '']) {
    DateTime? parsedDate;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is Timestamp) {
      parsedDate = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      parsedDate = DateTime.tryParse(rawCreatedAt);
    } else if (rawCreatedAt is DateTime) {
      parsedDate = rawCreatedAt;
    }

    return StockItem(
      id: id,
      sku: (data['sku'] as String? ?? '').trim(),
      itemName: (data['itemName'] as String? ?? '').trim(),
      category: (data['category'] as String? ?? 'Electronics').trim(),
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      reorderLevel: (data['reorderLevel'] as num?)?.toInt() ?? 0,
      createdAt: parsedDate ?? DateTime.now(),
    );
  }

  StockItem copyWith({
    String? id,
    String? sku,
    String? itemName,
    String? category,
    int? quantity,
    double? unitPrice,
    int? reorderLevel,
    DateTime? createdAt,
  }) {
    return StockItem(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
