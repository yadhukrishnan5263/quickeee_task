
import '../../feature/data/datasources/local/asset_datasource.dart';
import '../../feature/data/repositories/product_repository_impl.dart';
import '../../feature/domain/repositories/product_repository.dart';
import '../../feature/domain/usecases/get_product_data_usecase.dart';

class DependencyInjection {
  static late final ProductRepository _productRepository;
  static late final GetProductDataUseCase _getProductDataUseCase;

  static void initialize() {
    final dataSource = AssetDataSource();
    _productRepository = ProductRepositoryImpl(dataSource: dataSource);
    _getProductDataUseCase = GetProductDataUseCase(_productRepository);
  }

  static ProductRepository get productRepository => _productRepository;
  static GetProductDataUseCase get getProductDataUseCase => _getProductDataUseCase;
}
