import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_inventory_app/screens/stock_entry_form.dart';

void main() {
  testWidgets('Task 1: Stock Entry Form renders all 6 compulsory inputs and Save button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StockEntryForm(),
        ),
      ),
    );

    // Verify all 6 compulsory fields exist
    expect(find.text('Stock Item Entry'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5)); // SKU, Name, Qty, Price, Reorder
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget); // Category
    expect(find.text('Save Item'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });

  testWidgets('Task 1: Submitting empty form displays inline validation errors',
      (WidgetTester tester) async {
    // Set view size large enough to avoid scrolling issues in test
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StockEntryForm(),
        ),
      ),
    );

    // Scroll to and tap Save Item
    final saveButtonFinder = find.text('Save Item');
    await tester.ensureVisible(saveButtonFinder);
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    // Verify inline field-level validation errors appear
    expect(find.text('SKU is required'), findsOneWidget);
    expect(find.text('Item name is required'), findsOneWidget);
    expect(find.text('Please select a category'), findsOneWidget);
    expect(find.text('Quantity is required'), findsOneWidget);
    expect(find.text('Unit price is required'), findsOneWidget);
    expect(find.text('Reorder level is required'), findsOneWidget);
  });
}
