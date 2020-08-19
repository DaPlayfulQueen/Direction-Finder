import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocatorBloc extends Bloc<LocatorEvent, LocatorState> {
  Position userPosition;
  Position destinationPosition;
  double lastKnownDistance = DISTANCE_INIT;
  double lastKnownAngle = ANGLE_INIT;
  TurnDirection lastKnownTurnDirection;

  final Geolocator _geolocator = Geolocator();
  final Stream<double> _compass = FlutterCompass.events;
  final Geodesy _geodesy = Geodesy();

  Stream compassStream;

  StreamSubscription compassSubscription;
  StreamSubscription positionSubscription;

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
      userPosition = await getUserPositionOnce();
      lastKnownDistance = await getDistance(userPosition, destinationPosition);
      yield DestinationCoordsSet(distance:  lastKnownDistance);
    }

    if (event is StartListenUserPosition) {
      await initCompass();
      await initRangeFinder();
      yield UserPositionUpdated(lastKnownDistance, lastKnownAngle, lastKnownTurnDirection);
    }

    if (event is StopListenUserPosition) {
      yield UserPositionUpdated(lastKnownDistance, lastKnownAngle, lastKnownTurnDirection);
    }

  }

  Future<void> initCompass() async {
    compassStream = _compass.asyncMap((double directionAngle) async {
      var userPosition = await getUserPositionOnce();

      LatLng destinationLatLng =
          LatLng(destinationPosition.latitude, destinationPosition.longitude);

      LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
      var bearingAngle =
          _geodesy.bearingBetweenTwoGeoPoints(userLatLng, destinationLatLng);

      if (bearingAngle > directionAngle) {
        var baseAngle = bearingAngle - directionAngle;
        if (baseAngle < 180) {
          lastKnownAngle = baseAngle;
          lastKnownTurnDirection = TurnDirection.right;
        } else {
          lastKnownAngle = 360 - baseAngle;
          lastKnownTurnDirection = TurnDirection.left;
        }
      } else {
        var baseAngle = directionAngle - bearingAngle;
        if (baseAngle < 180) {
          lastKnownAngle = baseAngle;
          lastKnownTurnDirection = TurnDirection.left;
        } else {
          lastKnownAngle = 360 - baseAngle;
          lastKnownTurnDirection = TurnDirection.right;
        }
      }

      return UserPositionUpdated(lastKnownDistance, lastKnownAngle, lastKnownTurnDirection);
    });
  }

  Future<void> initRangeFinder() async {
    Stream<Position> positionStream = Geolocator()
        .getPositionStream(LocationOptions(accuracy: desiredAccuracy));
    positionSubscription = positionStream.listen((Position position) async* {
      userPosition = position;
      lastKnownDistance = await getDistance(userPosition, destinationPosition);
      yield UserPositionUpdated(lastKnownDistance, lastKnownAngle, lastKnownTurnDirection);
    });
  }

  Future<Position> getUserPositionOnce() async {
    return _geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy);
  }

  void setDestinationPosition(double lat, double long) {
    destinationPosition = Position(latitude: lat, longitude: long);
  }

  void setInitialDistanceToPosition(double distance) {
    this.lastKnownDistance = distance;
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

  void reset() {
    positionSubscription.cancel();
    compassSubscription.cancel();
    userPosition = null;
    destinationPosition = null;
    lastKnownDistance = DISTANCE_INIT;
    lastKnownAngle = ANGLE_INIT;
    lastKnownTurnDirection = null;
  }
}

abstract class LocatorEvent {}

class NewTargetCoords extends LocatorEvent {
  double latitude;
  double longitude;

  NewTargetCoords(this.latitude, this.longitude);
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
