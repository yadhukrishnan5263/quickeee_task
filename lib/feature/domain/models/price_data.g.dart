// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceData _$PriceDataFromJson(Map<String, dynamic> json) => PriceData(
  price: (json['price'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  volume: (json['volume'] as num).toInt(),
);

Map<String, dynamic> _$PriceDataToJson(PriceData instance) => <String, dynamic>{
  'price': instance.price,
  'timestamp': instance.timestamp.toIso8601String(),
  'volume': instance.volume,
};
