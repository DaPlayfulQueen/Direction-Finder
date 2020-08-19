import 'package:json_annotation/json_annotation.dart';

part 'app_state.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AppState {

  AppState(this.currentScreen, this.destinationLat, this.destinationLong,
      this.destinationName);

  String currentScreen;
  double destinationLat;
  double destinationLong;
  String destinationName;

  factory AppState.fromJson(Map<String, dynamic> json) => _$AppStateFromJson(json);

  Map<String, dynamic> toJson() => _$AppStateToJson(this);

}
