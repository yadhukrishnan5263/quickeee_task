import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/price_data.dart';
import '../../domain/usecases/get_product_data_usecase.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductDataUseCase _getProductDataUseCase;

  ProductBloc({required GetProductDataUseCase getProductDataUseCase})
      : _getProductDataUseCase = getProductDataUseCase,
        super(const ProductState()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<PriceUpdated>(_onPriceUpdated);
    on<InventoryUpdated>(_onInventoryUpdated);
  }

  Future<void> _onLoadInitialData(
    LoadInitialData event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final historicalData = await _getProductDataUseCase.getHistoricalData();
      final initialLiveData = historicalData.length > 100 
          ? historicalData.sublist(historicalData.length - 100)
          : historicalData;
      final currentPrice = historicalData.isNotEmpty 
          ? historicalData.last.price
          : 1000.0;
      
      emit(state.copyWith(
        historicalData: historicalData,
        liveData: initialLiveData,
        currentPrice: currentPrice,
        isLoading: false,
      ));
      await for (final update in _getProductDataUseCase.getPriceStream()) {
        add(PriceUpdated(update.price));
        add(InventoryUpdated(update.inventory));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onPriceUpdated(
    PriceUpdated event,
    Emitter<ProductState> emit,
  ) async {
    final newLiveData = List<PriceData>.from(state.liveData);
    
    if (newLiveData.length >= 100) {
      newLiveData.removeAt(0);
    }
    
    newLiveData.add(PriceData(
      price: event.price,
      timestamp: DateTime.now(),
      volume: 100,
    ));

    emit(state.copyWith(
      currentPrice: event.price,
      liveData: newLiveData,
    ));
  }

  Future<void> _onInventoryUpdated(
    InventoryUpdated event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(remainingInventory: event.inventory));
  }
}
