import 'dart:async';
import '../models/price_data.dart';

abstract class ProductRepository {
  Future<List<PriceData>> getHistoricalData();
  Stream<PriceUpdate> getPriceStream();
}

class PriceUpdate {
  final double price;
  final int inventory;

  const PriceUpdate({
    required this.price,
    required this.inventory,
  });
}
