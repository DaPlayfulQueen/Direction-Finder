import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'consts.dart';

class Locator {
  Position userPosition;
  Position targetPosition;
  double distance;
  Geolocator _geolocator = Geolocator();
  StreamSubscription<Position> _positionStreamSubscription;

  final LocationAccuracy desiredAccuracy = LocationAccuracy.best;

  Future<Position> getUserPositionOnce() async {
    return _geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy);
  }

  void setTargetPosition(double lat, double long) {
    targetPosition = Position(latitude: lat, longitude: long);
  }

  void setInitialDistanceToPosition(double distance) {
    this.distance = distance;
  }

  Future<double> calculateDistanceOnce(
      Position userPosition, Position targetPosition) async {

    var targetLat = targetPosition.latitude;
    var targetLong = targetPosition.longitude;

    if (targetLat < -90 || targetLat > 90 || targetLong < -180 || targetLong > 180) {
      return DISTANCE_ERROR;
    }

    return _geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        targetLat,
        targetLong);
  }

  void setUserLocationListener() {

  }
}
