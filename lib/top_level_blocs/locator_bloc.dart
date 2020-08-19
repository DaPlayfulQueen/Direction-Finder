import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/models/app_state.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocatorBloc extends Bloc<LocatorEvent, LocatorState> {
  Position _userPosition;
  Position _destinationPosition =
      Position(latitude: COORD_INIT, longitude: COORD_INIT);
  String _destinationName;
  double _lastKnownDistance = DISTANCE_INIT;
  double _lastKnownAngle = ANGLE_INIT;
  TurnDirection _lastKnownTurnDirection;

  final Geolocator _geolocator = Geolocator();
  final Stream<double> _compass = FlutterCompass.events;
  final Geodesy _geodesy = Geodesy();

  Stream compassStream;
  Stream positionStream;

  final LocationAccuracy desiredAccuracy = LocationAccuracy.best;

  NavigationState _navigationState;

  SharedPreferences _sharedPreferences;

  LocatorBloc() : super(LocationTrackingDisabled());

  @override
  Stream<LocatorState> mapEventToState(LocatorEvent event) async* {
    if (event is ScreenUpdated) {
      _navigationState = event.navigationState;
      saveState();
      yield NavigationStored();
    }

    if (event is RestoreState) {
      restoreState();
      yield AppStateRestored(_navigationState);
    }

    if (event is CalculateIfRestored) {
      _userPosition = await getUserPositionOnce();
      _lastKnownDistance =
          await getDistance(_userPosition, _destinationPosition);
      yield DistanceCalculated(
          distance: _lastKnownDistance,
          lat: _destinationPosition.latitude,
          long: _destinationPosition.longitude,
          name: _destinationName);
    }

    if (event is NewTargetCoords) {
      setDestinationPosition(event.latitude, event.longitude);
      _destinationName = event.name;
      _userPosition = await getUserPositionOnce();
      _lastKnownDistance =
          await getDistance(_userPosition, _destinationPosition);
      saveState();
      yield DistanceCalculated(
          distance: _lastKnownDistance,
          lat: _destinationPosition.latitude,
          long: _destinationPosition.longitude,
          name: _destinationName);
    }

    if (event is StartListenUserPosition) {
      await initCompass();
      await initRangeFinder();
      yield UserPositionUpdated(
          _lastKnownDistance, _lastKnownAngle, _lastKnownTurnDirection);
    }

    if (event is StopListenUserPosition) {
      resetStreams();
      yield UserPositionUpdated(
          _lastKnownDistance, _lastKnownAngle, _lastKnownTurnDirection);
    }

    if (event is ExitScreen) {
      removeScreenPreference();
      _navigationState = null;
      yield LocationTrackingDisabled();
    }
  }

  Future<void> initCompass() async {
    compassStream = _compass.asyncMap((double directionAngle) async {
      var userPosition = await getUserPositionOnce();

      LatLng destinationLatLng =
          LatLng(_destinationPosition.latitude, _destinationPosition.longitude);

      LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
      var bearingAngle =
          _geodesy.bearingBetweenTwoGeoPoints(userLatLng, destinationLatLng);

      if (bearingAngle > directionAngle) {
        var baseAngle = bearingAngle - directionAngle;
        if (baseAngle < 180) {
          _lastKnownAngle = baseAngle;
          _lastKnownTurnDirection = TurnDirection.right;
        } else {
          _lastKnownAngle = 360 - baseAngle;
          _lastKnownTurnDirection = TurnDirection.left;
        }
      } else {
        var baseAngle = directionAngle - bearingAngle;
        if (baseAngle < 180) {
          _lastKnownAngle = baseAngle;
          _lastKnownTurnDirection = TurnDirection.left;
        } else {
          _lastKnownAngle = 360 - baseAngle;
          _lastKnownTurnDirection = TurnDirection.right;
        }
      }

      return UserPositionUpdated(
          _lastKnownDistance, _lastKnownAngle, _lastKnownTurnDirection);
    });
  }

  Future<void> initRangeFinder() async {
    positionStream = Geolocator()
        .getPositionStream(LocationOptions(accuracy: desiredAccuracy))
        .asyncMap((Position position) async {
      _userPosition = position;
      _lastKnownDistance =
          await getDistance(_userPosition, _destinationPosition);
      return UserPositionUpdated(
          _lastKnownDistance, _lastKnownAngle, _lastKnownTurnDirection);
    });
  }

  Future<Position> getUserPositionOnce() async {
    return _geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy);
  }

  void setDestinationPosition(double lat, double long) {
    _destinationPosition = Position(latitude: lat, longitude: long);
  }

  void setInitialDistanceToPosition(double distance) {
    this._lastKnownDistance = distance;
  }

  Future<double> getDistance(
      Position userPosition, Position targetPosition) async {
    var targetLat = targetPosition.latitude;
    var targetLong = targetPosition.longitude;

    if (targetLat < -90 ||
        targetLat > 90 ||
        targetLong < -180 ||
        targetLong > 180) {
      return DISTANCE_ERROR;
    }

    return _geolocator.distanceBetween(
        userPosition.latitude, userPosition.longitude, targetLat, targetLong);
  }

  void resetStreams() {
    compassStream = null;
    positionStream = null;
    _userPosition = null;
    _lastKnownDistance = DISTANCE_INIT;
    _lastKnownAngle = ANGLE_INIT;
    _lastKnownTurnDirection = null;
  }

  void saveState() {
    var appState = AppState(
        EnumToString.parse(_navigationState),
        _destinationPosition.latitude,
        _destinationPosition.longitude,
        _destinationName);
    var appStateJson = json.encode(appState);
    _sharedPreferences.setString(APP_STATE_KEY, appStateJson);
  }

  void saveStateWithoutNavigation() {
    var appState = AppState(
        EnumToString.parse(null),
        _destinationPosition.latitude,
        _destinationPosition.longitude,
        _destinationName);
    var appStateJson = json.encode(appState);
    _sharedPreferences.setString(APP_STATE_KEY, appStateJson);
    print("The state saved $appStateJson");
  }

  Future<bool> getPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return true;
  }

  bool isCoordsRestored() {
    return _destinationPosition.longitude != COORD_INIT;
  }

  void restoreState() {
    print("RESTORING STATE");
    var appStateString = _sharedPreferences.getString(APP_STATE_KEY);
    if (appStateString == null) {
      return;
    }
    var appStateJson = json.decode(appStateString);
    var appState = AppState.fromJson(appStateJson);
    _destinationName = appState.destinationName;
    _destinationPosition = Position(
        latitude: appState.destinationLat, longitude: appState.destinationLong);
    _navigationState =
        EnumToString.fromString(NavigationState.values, appState.currentScreen);
  }

  void removeScreenPreference() {
    _sharedPreferences.remove(APP_STATE_KEY);
    saveStateWithoutNavigation();
  }
}

abstract class LocatorEvent {}

class NewTargetCoords extends LocatorEvent {
  double latitude;
  double longitude;
  String name;

  NewTargetCoords(this.latitude, this.longitude, {this.name});
}

class StartListenUserPosition extends LocatorEvent {}

class StopListenUserPosition extends LocatorEvent {}

class ScreenUpdated extends LocatorEvent {
  NavigationState navigationState;

  ScreenUpdated(this.navigationState);
}

class RestoreState extends LocatorEvent {}

class CalculateIfRestored extends LocatorEvent {}

class ExitScreen extends LocatorEvent {}

abstract class LocatorState {}

class LocationTrackingDisabled extends LocatorState {}

class DistanceCalculated extends LocatorState {
  double distance;
  double lat;
  double long;
  String name;

  DistanceCalculated({this.distance, this.lat, this.long, this.name});
}

class UserPositionUpdated extends LocatorState {
  double distance;
  double angle;
  TurnDirection turnDirection;

  UserPositionUpdated(this.distance, this.angle, this.turnDirection);
}

class NavigationStored extends LocatorState {}

class AppStateRestored extends LocatorState {
  NavigationState navigationState;

  AppStateRestored(this.navigationState);
}

enum TurnDirection { left, right }
