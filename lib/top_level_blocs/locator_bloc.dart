import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocatorBloc extends Bloc<LocatorEvent, LocatorState> {
  Position _userPosition;
  Position _destinationPosition;
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

  SharedPreferences _sharedPreferences;

  LocatorBloc() : super(LocationTrackingDisabled()) {
    SharedPreferences.getInstance().then((instance) {
      _sharedPreferences = instance;
      _sharedPreferences.setString(SCREEN_KEY, SCREEN_COORD);
    });
  }

  @override
  Stream<LocatorState> mapEventToState(LocatorEvent event) async* {
    if (event is NewTargetCoords) {
      setDestinationPosition(event.latitude, event.longitude);
      _userPosition = await getUserPositionOnce();
      _lastKnownDistance =
          await getDistance(_userPosition, _destinationPosition);
      yield DestinationCoordsSet(distance: _lastKnownDistance);
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
    _destinationPosition = null;
    _lastKnownDistance = DISTANCE_INIT;
    _lastKnownAngle = ANGLE_INIT;
    _lastKnownTurnDirection = null;
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

abstract class LocatorState {}

class LocationTrackingDisabled extends LocatorState {}

class DestinationCoordsSet extends LocatorState {
  double distance;

  DestinationCoordsSet({this.distance = DISTANCE_INIT});
}

class UserPositionUpdated extends LocatorState {
  double distance;
  double angle;
  TurnDirection turnDirection;

  UserPositionUpdated(this.distance, this.angle, this.turnDirection);
}

enum TurnDirection { left, right }
