import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/inventory_list_screen.dart';
import 'screens/stock_entry_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  String? firebaseError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
    firebaseError = e.toString();
  }

  runApp(StockInventoryApp(
    firebaseInitialized: firebaseInitialized,
    firebaseError: firebaseError,
  ));
}

class StockInventoryApp extends StatelessWidget {
  final bool firebaseInitialized;
  final String? firebaseError;

  const StockInventoryApp({
    super.key,
    required this.firebaseInitialized,
    this.firebaseError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Inventory Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5), // Indigo/Blue theme
          brightness: Brightness.light,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF9FAFB),
        ),
      ),
      home: HomeScreen(
        firebaseInitialized: firebaseInitialized,
        firebaseError: firebaseError,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool firebaseInitialized;
  final String? firebaseError;

  const HomeScreen({
    super.key,
    required this.firebaseInitialized,
    this.firebaseError,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const InventoryListScreen(),
      StockEntryForm(
        onSaveSuccess: () {
          // Automatically switch to inventory list tab to observe the newly added item
          setState(() => _currentIndex = 0);
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock Inventory Manager',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'NET4207 Cross Platform Mobile App Dev • Project: ${DefaultFirebaseOptions.projectId}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Lab Test Information',
            onPressed: () => _showAppInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!widget.firebaseInitialized && widget.firebaseError != null)
            MaterialBanner(
              backgroundColor: Colors.amber.shade100,
              leading: const Icon(Icons.warning, color: Colors.orange),
              content: Text(
                'Note: Using local fallback or pending live Firebase credentials.\n'
                '${widget.firebaseError}',
                style: const TextStyle(fontSize: 12),
              ),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text('DISMISS'),
                ),
              ],
            ),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory & Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Add Stock Item',
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NET4207 Lab Test Summary'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Subject: NET4207 Cross Platform Mobile App Dev',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Technologies: Flutter, Cloud Firestore, GitHub'),
              Text('Target Collection: stockItems'),
              Text('Firebase Project ID: net4207-stock-inventory'),
              SizedBox(height: 12),
              Text('Tasks Implemented:'),
              Text('• Task 1: Stock Entry Form with 6 Validated Fields'),
              Text('• Task 2: Firestore Save (with timestamp) & Real-time Readback'),
              Text('• Task 3: Advanced Combined Search, Low-Stock Filter, Quantity Sort'),
              Text('• Task 4: Comprehensive README Documentation & Test Log'),
              Text('• Task 5: Robust UX with Loading, Empty & Error States'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
