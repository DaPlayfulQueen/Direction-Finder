import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TurnDirection { left, right }

class LocatorBloc extends Bloc<LocatorEvent, LocatorState> {
  Position userPosition;
  Position destinationPosition;
  double lastKnownDistance = DISTANCE_INIT;
  double lastKnownAngle;
  TurnDirection turnDirection;

  final Geolocator _geolocator = Geolocator();
  final Stream<double> _compass = FlutterCompass.events;
  final Geodesy _geodesy = Geodesy();
  StreamSubscription _compassListener;
  StreamSubscription _positionListener;

  final LocationAccuracy desiredAccuracy = LocationAccuracy.best;

  SharedPreferences _sharedPreferences;

  LocatorBloc() : super(LocatorAtStart()) {
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
      yield CoordsUpdated(lastKnownDistance);
    }

  }

  void initCompass() async {
    _compassListener = _compass.listen((double directionAngle) {
      getUserPositionOnce().then((userPosition) async* {
        LatLng destinationLatLng =
            LatLng(destinationPosition.latitude, destinationPosition.longitude);

        var userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
        var bearingAngle =
            _geodesy.bearingBetweenTwoGeoPoints(userLatLng, destinationLatLng);

        if (bearingAngle > directionAngle) {
          var baseAngle = bearingAngle - directionAngle;
          if (baseAngle < 180) {
            lastKnownAngle = baseAngle;
            turnDirection = TurnDirection.right;
          } else {
            lastKnownAngle = 360 - baseAngle;
            turnDirection = TurnDirection.left;
          }
        } else {
          var baseAngle = directionAngle - bearingAngle;
          if (baseAngle < 180) {
            lastKnownAngle = baseAngle;
            turnDirection = TurnDirection.left;
          } else {
            lastKnownAngle = 360 - baseAngle;
            turnDirection = TurnDirection.right;
          }
        }

        yield LocatorOnFinderScreen(lastKnownDistance, lastKnownAngle);
      });
    });
  }

  void initRangeFinder() async {
    Stream<Position> positionStream = Geolocator()
        .getPositionStream(LocationOptions(accuracy: desiredAccuracy));
    _positionListener = positionStream.listen((Position position) async* {
      userPosition = position;
      lastKnownDistance = await getDistance(userPosition, destinationPosition);
      yield LocatorOnFinderScreen(lastKnownDistance, lastKnownAngle);
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
    _positionListener.cancel();
    _compassListener.cancel();
    userPosition = null;
    destinationPosition = null;
    lastKnownDistance = DISTANCE_INIT;
    lastKnownAngle = null;
    turnDirection = null;
  }

}

abstract class LocatorEvent {}

class NewTargetCoords extends LocatorEvent {
  double latitude;
  double longitude;

  NewTargetCoords(this.latitude, this.longitude);
}

class ActivateListeners extends LocatorEvent {}

abstract class LocatorState {
  double distance;

  LocatorState({this.distance = DISTANCE_INIT});
}

class CoordsUpdated extends LocatorState {
  CoordsUpdated(distance) : super(distance: distance);
}

class LocatorAtStart extends LocatorState {
}

class LocatorOnFinderScreen extends LocatorState {
  double distance;
  double angle;

  LocatorOnFinderScreen(this.distance, this.angle);
}
