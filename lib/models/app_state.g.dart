// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) {
  return AppState(
    json['current_screen'] as String,
    (json['destination_lat'] as num)?.toDouble(),
    (json['destination_long'] as num)?.toDouble(),
    json['destination_name'] as String,
  );
}

Map<String, dynamic> _$AppStateToJson(AppState instance) => <String, dynamic>{
      'current_screen': instance.currentScreen,
      'destination_lat': instance.destinationLat,
      'destination_long': instance.destinationLong,
      'destination_name': instance.destinationName,
    };
