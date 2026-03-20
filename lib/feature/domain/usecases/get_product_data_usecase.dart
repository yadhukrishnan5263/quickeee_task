import '../models/price_data.dart';
import '../repositories/product_repository.dart';

class GetProductDataUseCase {
  final ProductRepository _repository;

  GetProductDataUseCase(this._repository);

  Future<List<PriceData>> getHistoricalData() async {
    return await _repository.getHistoricalData();
  }

  Stream<PriceUpdate> getPriceStream() {
    return _repository.getPriceStream();
  }
}
