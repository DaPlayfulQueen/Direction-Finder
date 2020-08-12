import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:pelengator/common_utils/consts.dart';

class Locator {
  Position userPosition;
  Position targetPosition;
  double distance;
  Geolocator geolocator = Geolocator();
  StreamSubscription<Position> _positionStreamSubscription;

  final LocationAccuracy desiredAccuracy = LocationAccuracy.best;

  Future<Position> getUserPositionOnce() async {
    return geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy);
  }

  void setTargetPosition(double lat, double long) {
    targetPosition = Position(latitude: lat, longitude: long);
  }

  Future<double> calculateDistanceOnce(
      Position userPosition, Position targetPosition) async {

    var targetLat = targetPosition.latitude;
    var targetLong = targetPosition.longitude;

    if (targetLat < -90 || targetLat > 90 || targetLong < -180 || targetLong > 180) {
      return DISTANCE_ERROR;
    }

    return geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        targetLat,
        targetLong);
  }

  void setUserLocationListener() {}
}
