part of 'product_bloc.dart';

class ProductState extends Equatable {
  final double currentPrice;
  final int remainingInventory;
  final List<PriceData> historicalData;
  final List<PriceData> liveData;
  final bool isLoading;
  final String? error;

  const ProductState({
    this.currentPrice = 0.0,
    this.remainingInventory = 0,
    this.historicalData = const [],
    this.liveData = const [],
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    double? currentPrice,
    int? remainingInventory,
    List<PriceData>? historicalData,
    List<PriceData>? liveData,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      currentPrice: currentPrice ?? this.currentPrice,
      remainingInventory: remainingInventory ?? this.remainingInventory,
      historicalData: historicalData ?? this.historicalData,
      liveData: liveData ?? this.liveData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        currentPrice,
        remainingInventory,
        historicalData,
        liveData,
        isLoading,
        error,
      ];
}

enum PurchaseButtonState {
  idle,
  holding,
  loading,
  success,
  failed,
}
