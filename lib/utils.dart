import 'package:pelengator/commons/consts.dart';

String getDistanceString(double distance) {
  if (distance == DISTANCE_INIT) {
    return "";
  }

  if (distance == DISTANCE_ERROR) {
    return "Calculation error! Looks like coordinates are incorrect";
  }

  return distance.toString() + " kms";
}
