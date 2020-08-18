import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';

import 'consts.dart';

class Locator {
  Position userPosition;
  Position destinationPosition;
  double lastKnownDistance;
  double lastKnownAngle;
  TurnDirection turnDirection;

  //final?
  final Geolocator _geolocator = Geolocator();
  final Stream<double> _compass = FlutterCompass.events;
  final Geodesy _geodesy = Geodesy();
  StreamSubscription _compassListener;
  StreamSubscription _positionListener;


  final LocationAccuracy desiredAccuracy = LocationAccuracy.best;

  void initCompass(Function updateView) async {
    await updateUserPosition();
    _compassListener = _compass.listen((double directionAngle) async* {
      LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
      LatLng destinationLatLng =
          LatLng(destinationPosition.latitude, destinationPosition.longitude);

      var bearingAngle =
          _geodesy.bearingBetweenTwoGeoPoints(userLatLng, destinationLatLng);

      print(
          "The bearing angle is $bearingAngle, user direction is $directionAngle");

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

      print("The angle is $lastKnownAngle, turn direction is $turnDirection");
      updateView();

//    yield lastKnownAngle;

    });
  }

  void initRangeFinder(Function updateView) async {
    const LocationOptions locationOptions =
        LocationOptions(accuracy: LocationAccuracy.best);
    Stream<Position> positionStream =
        Geolocator().getPositionStream(locationOptions);
    _positionListener = positionStream.listen((Position position) async* {
      userPosition = position;
      lastKnownDistance = await calculateDistance(userPosition, destinationPosition);
      updateView();
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

  Future<double> calculateDistance(
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

  void updateUserPosition() async {
    userPosition = await getUserPositionOnce();
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

enum TurnDirection { left, right }
