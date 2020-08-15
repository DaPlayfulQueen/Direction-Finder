import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';

import 'consts.dart';

class Locator {
  Position userPosition;
  Position destinationPosition;
  double distance;
  double angleBetween;
  TurnDirection turnDirection;

  //final? 
  final Geolocator _geolocator = Geolocator();
  final Stream<double> _compass = FlutterCompass.events;
  final Geodesy _geodesy = Geodesy();
  StreamSubscription<Position> _positionStreamSubscription;

  final LocationAccuracy desiredAccuracy = LocationAccuracy.best;

  void initCompass(Function updateView) {
    updateUserPosition();
    _compass.listen((double angleDirection) async {
      LatLng userLatLng = LatLng(userPosition.latitude, userPosition.longitude);
      LatLng destinationLatLng = LatLng(
          destinationPosition.latitude, destinationPosition.longitude);
      var bearingAngle = _geodesy.bearingBetweenTwoGeoPoints(
          userLatLng, destinationLatLng);

      if (bearingAngle > angleDirection) {
        if (bearingAngle < 180) {
          angleBetween = bearingAngle - angleDirection;
          turnDirection = TurnDirection.left;
        } else {
          angleBetween = 360 - (bearingAngle - angleDirection);
          turnDirection = TurnDirection.right;
        }
      } else {
        if (angleDirection < 180) {
          angleBetween = angleDirection - bearingAngle;
          turnDirection = TurnDirection.left;
        } else {
          angleBetween = 360 - (angleDirection - bearingAngle);
          turnDirection = TurnDirection.right;
        }
      }

      updateView();
    });
  }

  void initRangeFinder(Function updateView) async {
    updateUserPosition();
    const LocationOptions locationOptions =
    LocationOptions(accuracy: LocationAccuracy.best);
    Stream<Position> positionStream =
    Geolocator().getPositionStream(locationOptions);
    _positionStreamSubscription = positionStream.listen(
            (Position position) async {
              userPosition = position;
           distance = await calculateDistance(userPosition, destinationPosition);
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
    this.distance = distance;
  }

  Future<double> calculateDistance(Position userPosition,
      Position targetPosition) async {
    var targetLat = targetPosition.latitude;
    var targetLong = targetPosition.longitude;

    if (targetLat < -90 || targetLat > 90 || targetLong < -180 ||
        targetLong > 180) {
      return DISTANCE_ERROR;
    }

    return _geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        targetLat,
        targetLong);
  }

  void updateUserPosition() async {
    userPosition = await getUserPositionOnce();
  }
}

enum TurnDirection {
  left,
  right
}