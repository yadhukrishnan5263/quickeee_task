
import '../../domain/models/price_data.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/asset_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AssetDataSource _dataSource;

  ProductRepositoryImpl({AssetDataSource? dataSource}) 
      : _dataSource = dataSource ?? AssetDataSource();

  @override
  Future<List<PriceData>> getHistoricalData() async {
    return await _dataSource.getHistoricalData();
  }

  @override
  Stream<PriceUpdate> getPriceStream() async* {
    yield* _dataSource.getPriceStream();
  }
}
