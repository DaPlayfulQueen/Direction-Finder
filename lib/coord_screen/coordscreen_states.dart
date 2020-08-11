abstract class CoordScreenState {}

class DistanceCalculated extends CoordScreenState {

  double userLatitude;
  double userLongitude;
  double destinationLatitude;
  double destinationLongitude;

  double distance;

}

class CalculationFailed extends CoordScreenState {}

class InitialState extends DistanceCalculated {}

abstract class CoordScreenEvent {}