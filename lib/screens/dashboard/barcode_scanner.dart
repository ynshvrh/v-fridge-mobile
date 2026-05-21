import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/api_models.dart';

class ScannedProduct {
  final String barcode;
  final String name;
  final String category;
  final String unit;
  final String quantity;

  const ScannedProduct({
    required this.barcode,
    required this.name,
    required this.category,
    required this.unit,
    required this.quantity,
  });
}

/// Wraps mobile_scanner. Returns a [ScannedProduct] (looked up against OpenFoodFacts) or null
/// if the user cancelled / nothing matched.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE, BarcodeFormat.code128],
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 1000,
  );
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || !RegExp(r'^\d{6,14}$').hasMatch(raw)) return;

    setState(() { _processing = true; _error = null; });
    await _controller.stop();
    try {
      final product = await _lookupOpenFoodFacts(raw);
      if (!mounted) return;
      if (product == null) {
        setState(() { _processing = false; _error = 'Product not found in OpenFoodFacts'; });
        await _controller.start();
        return;
      }
      Navigator.of(context).pop(product);
    } catch (e) {
      if (!mounted) return;
      setState(() { _processing = false; _error = e.toString(); });
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 240,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_processing)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x88000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Future<ScannedProduct?> _lookupOpenFoodFacts(String barcode) async {
  final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));
  final response = await dio.get('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
  if (response.statusCode != 200) return null;
  final data = response.data as Map<String, dynamic>;
  if (data['status'] != 1 || data['product'] is! Map<String, dynamic>) return null;
  return _mapOffProduct(barcode, data['product'] as Map<String, dynamic>);
}

ScannedProduct _mapOffProduct(String barcode, Map<String, dynamic> p) {
  final name = ((p['product_name_en'] as String?)?.trim()
              ?? (p['product_name'] as String?)?.trim()
              ?? (p['brands'] as String?)?.trim()
              ?? 'Unknown product');
  final tags = ((p['categories_tags'] as List?) ?? const []).cast<String>();
  final category = _mapCategory(tags);
  final qa = _parseQuantity(p['quantity'] as String?);
  return ScannedProduct(barcode: barcode, name: name, category: category, unit: qa.unit, quantity: qa.quantity);
}

String _mapCategory(List<String> tags) {
  final flat = tags.join(' ').toLowerCase();
  const patterns = <List<dynamic>>[
    [r'milk|cheese|yogurt|butter|cream|dairy', 'dairy'],
    [r'meat|fish|seafood|sausage|poultry|beef|pork|chicken', 'meat-fish'],
    [r'vegetable|salad|herb|mushroom|green', 'vegetables'],
    [r'fruit|berry|berries|apple|banana|orange', 'fruits'],
    [r'bread|bakery|pastry|bun|cake|cookie', 'bakery'],
    [r'pasta|grain|rice|flour|sugar|salt|cereal|oat', 'pantry'],
    [r'chip|snack|sweet|chocolate|candy|nut', 'snacks'],
    [r'water|juice|soda|coffee|tea|drink|beverage', 'drinks'],
    [r'beer|wine|spirit|alcohol|liqueur|vodka', 'alcohol'],
    [r'oil|vinegar|sauce|ketchup|mayo|spice|condiment', 'sauces'],
    [r'frozen|ice-cream', 'frozen'],
    [r'canned|preserve|ready-to-eat|ready-meal', 'canned-prepared'],
  ];
  for (final pair in patterns) {
    if (RegExp(pair[0] as String).hasMatch(flat)) return pair[1] as String;
  }
  return Categories.slugs.contains('other') ? 'other' : 'other';
}

({String quantity, String unit}) _parseQuantity(String? raw) {
  if (raw == null || raw.isEmpty) return (quantity: '1', unit: 'pcs');
  final m = RegExp(r'(\d+(?:[.,]\d+)?)\s*(kg|g|l|ml|cl)\b', caseSensitive: false).firstMatch(raw);
  if (m == null) return (quantity: '1', unit: 'pcs');
  var qty = m.group(1)!.replaceAll(',', '.');
  var unit = m.group(2)!.toLowerCase();
  if (unit == 'cl') {
    qty = ((double.tryParse(qty) ?? 1) * 10).toString();
    unit = 'ml';
  }
  return (quantity: qty, unit: unit);
}
