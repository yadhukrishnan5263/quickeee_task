part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadInitialData extends ProductEvent {
  const LoadInitialData();
}

class PriceUpdated extends ProductEvent {
  final double price;

  const PriceUpdated(this.price);

  @override
  List<Object> get props => [price];
}

class InventoryUpdated extends ProductEvent {
  final int inventory;

  const InventoryUpdated(this.inventory);

  @override
  List<Object> get props => [inventory];
}
