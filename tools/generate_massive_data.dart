import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main() {
  final random = Random();
  final List<Map<String, dynamic>> data = [];
  final now = DateTime.now();
  
  print('Generating 50,000 historical price data points...');
  
  // Generate 50,000 historical data points
  for (int i = 0; i < 50000; i++) {
    final timestamp = now.subtract(Duration(minutes: i * 5));
    final basePrice = 1000.0;
    final trend = sin(i * 0.001) * 200; // Long-term trend
    final volatility = (random.nextDouble() - 0.5) * 50; // Short-term volatility
    final price = basePrice + trend + volatility;
    final bid = price - (random.nextDouble() * 1.5);
    final ask = price + (random.nextDouble() * 1.5);
    final volume = random.nextInt(1000) + 100;
    final change = i > 0 ? price - data[i-1]['price'] : 0.0;
    final changePercent = i > 0 ? (change / data[i-1]['price']) * 100 : 0.0;
    
    data.add({
      'timestamp': timestamp.toIso8601String(),
      'price': double.parse(price.toStringAsFixed(2)),
      'volume': volume,
      'bid': double.parse(bid.toStringAsFixed(2)),
      'ask': double.parse(ask.toStringAsFixed(2)),
      'change': double.parse(change.toStringAsFixed(2)),
      'change_percent': double.parse(changePercent.toStringAsFixed(4)),
    });
    
    if (i % 10000 == 0) {
      print('Generated $i data points...');
    }
  }
  
  // Sort by timestamp (newest first for chart display)
  data.sort((a, b) => DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
  
  // Write to JSON file
  final file = File('assets/massive_price_data.json');
  final jsonString = JsonEncoder.withIndent('  ').convert(data);
  file.writeAsStringSync(jsonString);
  
  print('✅ Successfully generated ${data.length} data points');
  print('📁 File saved: ${file.path}');
  print('📊 File size: ${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB');
}

double sin(double x) {
  double result = 0;
  for (int i = 0; i < 10; i++) {
    int sign = (i % 2 == 0) ? 1 : -1;
    int factorial = 1;
    for (int j = 1; j <= (2 * i + 1); j++) {
      factorial *= j;
    }
    result += sign * (pow(x, (2 * i + 1)) / factorial);
  }
  return result;
}

double pow(double x, int exponent) {
  double result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}
