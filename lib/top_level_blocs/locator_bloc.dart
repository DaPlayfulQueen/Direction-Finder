import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pelengator/commons/consts.dart';

enum TurnDirection { left, right }

class LocatorBloc extends Bloc<LocatorEvent, LocatorState> {
  Position userPosition;
  Position destinationPosition;
  double lastKnownDistance;
  double lastKnownAngle;
  TurnDirection turnDirection;

  final Geolocator _geolocator = Geolocator();
  final Stream<double> _compass = FlutterCompass.events;
  final Geodesy _geodesy = Geodesy();
  StreamSubscription _compassListener;
  StreamSubscription _positionListener;

  final LocationAccuracy desiredAccuracy = LocationAccuracy.best;

  LocatorBloc() : super(LocatorAtStart());

  @override
  Stream<LocatorState> mapEventToState(LocatorEvent event) {}

  void initCompass(Function updateView) async {
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

        print(
            "The bearing angle is $bearingAngle, user direction is $directionAngle");
        print("The angle is $lastKnownAngle, turn direction is $turnDirection");

        yield LocatorOnFinderScreen(lastKnownDistance, lastKnownAngle);
      });
    });
  }

  void initRangeFinder(Function updateView) async {
    Stream<Position> positionStream =
        Geolocator().getPositionStream(LocationOptions(accuracy: desiredAccuracy));
    _positionListener = positionStream.listen((Position position) async* {
      userPosition = position;
      lastKnownDistance = await getDistance(userPosition, destinationPosition);
      yield LocatorOnFinderScreen(lastKnownDistance, lastKnownAngle)
    });
  }

  Future<Position> getUserPositionOnce() async {
    return _geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy);
  }

  void setTargetPosition(double lat, double long) {
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

class SetNewCoords extends LocatorEvent {
  double latitude;
  double longitude;

  SetNewCoords(this.latitude, this.longitude);
}

abstract class LocatorState {}

class LocatorAtStart extends LocatorState {}

class LocatorOnFinderScreen extends LocatorState {
  double distance;
  double angle;

  LocatorOnFinderScreen(this.distance, this.angle);
}
