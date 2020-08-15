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

  final LocationAccuracy desiredAccuracy = LocationAccuracy.best;

  void initCompass(Function updateView) async {
    await updateUserPosition();
    _compass.listen((double directionAngle) async {
      print("Compass updated");
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
          angleBetween = baseAngle;
          turnDirection = TurnDirection.right;
        } else {
          angleBetween = 360 - baseAngle;
          turnDirection = TurnDirection.left;
        }
      } else {
        var baseAngle = directionAngle - bearingAngle;
        if (baseAngle < 180) {
          angleBetween = baseAngle;
          turnDirection = TurnDirection.left;
        } else {
          angleBetween = 360 - baseAngle;
          turnDirection = TurnDirection.right;
        }
      }

      print("The angle is $angleBetween, turn direction is $turnDirection");
      updateView();
    });
  }

  void initRangeFinder(Function updateView) async {
    await updateUserPosition();
    const LocationOptions locationOptions =
        LocationOptions(accuracy: LocationAccuracy.best);
    Stream<Position> positionStream =
        Geolocator().getPositionStream(locationOptions);
    positionStream.listen((Position position) async {
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
}

enum TurnDirection { left, right }
