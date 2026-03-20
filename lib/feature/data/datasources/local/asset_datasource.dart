import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/services.dart';
import '../../../domain/models/price_data.dart';
import '../../../domain/repositories/product_repository.dart';

class AssetDataSource {
  static const _updateInterval = Duration(milliseconds: 800);
  
  Future<List<PriceData>> getHistoricalData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final jsonString = await rootBundle.loadString('assets/massive_price_data.json');
    
    return await _parseMassiveJsonInIsolate(jsonString);
  }

  Stream<PriceUpdate> getPriceStream() async* {
    double currentPrice = 1000.0;
    int currentInventory = 1000;
    final random = Random();
    
    while (true) {
      await Future.delayed(_updateInterval);
      
      final priceChange = (random.nextDouble() - 0.5) * 10;
      currentPrice = (currentPrice + priceChange).clamp(500.0, 2000.0);
      
      final inventoryChange = random.nextInt(5) - 2;
      currentInventory = (currentInventory + inventoryChange).clamp(0, 2000);
      
      yield PriceUpdate(
        price: double.parse(currentPrice.toStringAsFixed(2)),
        inventory: currentInventory,
      );
    }
  }

  Future<List<PriceData>> _parseMassiveJsonInIsolate(String jsonString) async {
    return await Isolate.run(() {
      final List<dynamic> jsonData = json.decode(jsonString);
      final List<PriceData> priceData = [];
      
      print('🔄 Parsing ${jsonData.length} JSON entries in isolate...');
      
      for (int i = 0; i < jsonData.length; i++) {
        final item = jsonData[i] as Map<String, dynamic>;
        
        priceData.add(PriceData(
          price: (item['price'] as num).toDouble(),
          timestamp: DateTime.parse(item['timestamp'] as String),
          volume: item['volume'] as int,
        ));
        
        if (i % 10000 == 0) {
          print('📊 Parsed $i entries...');
        }
      }
      
      print('✅ Successfully parsed ${priceData.length} price data points');
      return priceData;
    });
  }
}
