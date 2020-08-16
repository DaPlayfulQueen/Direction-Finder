import 'package:bloc/bloc.dart';
import 'package:native_state/native_state.dart';
import 'package:pelengator/commons/locator.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final Locator locator;

  NavigationBloc(NavigationState initialState, this.locator) : super(initialState);

  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {



    switch (event) {
      case NavigationEvent.toStartScreen:

        yield NavigationState.start;
        break;
      case NavigationEvent.toCoordinatesScreen:
        yield NavigationState.coordinates;
        break;
      case NavigationEvent.toAddressesScreen:
        yield NavigationState.addresses;
        break;
      case NavigationEvent.toFinderScreenAdd:
        yield NavigationState.finderAddress;
        break;
      case NavigationEvent.toFinderScreenCoord:
        yield NavigationState.finderCoordinates;
        break;
    }
  }
}

enum NavigationState { start, coordinates, addresses, finderAddress, finderCoordinates }

enum NavigationEvent {
  toStartScreen, toCoordinatesScreen, toAddressesScreen, toFinderScreenAdd, toFinderScreenCoord
}


