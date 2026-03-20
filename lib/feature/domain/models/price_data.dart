import 'package:json_annotation/json_annotation.dart';

part 'price_data.g.dart';

@JsonSerializable()
class PriceData {
  final double price;
  final DateTime timestamp;
  final int volume;

  const PriceData({
    required this.price,
    required this.timestamp,
    required this.volume,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) =>
      _$PriceDataFromJson(json);

  Map<String, dynamic> toJson() => _$PriceDataToJson(this);

  PriceData copyWith({
    double? price,
    DateTime? timestamp,
    int? volume,
  }) {
    return PriceData(
      price: price ?? this.price,
      timestamp: timestamp ?? this.timestamp,
      volume: volume ?? this.volume,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceData &&
          runtimeType == other.runtimeType &&
          price == other.price &&
          timestamp == other.timestamp &&
          volume == other.volume;

  @override
  int get hashCode => price.hashCode ^ timestamp.hashCode ^ volume.hashCode;
}

