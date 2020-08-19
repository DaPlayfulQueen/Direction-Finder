import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/top_level_blocs/locator_bloc.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';
import 'package:google_maps_webservice/places.dart';

class AddressScreen extends StatefulWidget {
  AddressScreen();

  @override
  State createState() => AddressScreenState();
}

class AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: API_KEY);

  double _inputLat;
  double _inputLong;
  TextEditingController _controller = TextEditingController();

  LocatorBloc _locatorBloc;

  @override
  void initState() {
    super.initState();
    _locatorBloc = BlocProvider.of<LocatorBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var locatorBloc = BlocProvider.of<LocatorBloc>(context);
    locatorBloc.add(ScreenUpdated(NavigationState.addresses));
    locatorBloc.add(CalculateIfRestored());


    return BlocBuilder<LocatorBloc, LocatorState>(builder: (context, state) {

      bool goingToRestore = state is DistanceCalculated && isAbleToRestore(state);

      _controller.text = goingToRestore ? (state as DistanceCalculated).name : "";
      _inputLat = goingToRestore ? (state as DistanceCalculated).lat : COORD_INIT;
      _inputLong = goingToRestore ? (state as DistanceCalculated).long : COORD_INIT;
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
            vertical: height * 0.1, horizontal: width * 0.1),
        child: Column(
          children: <Widget>[
            Container(
                child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Address'),
              ),
            )),
            Container(
              margin: EdgeInsets.only(top: height * 0.03),
              child: StyledButton('Find', () async {
                Prediction prediction = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: API_KEY,
                    mode: Mode.overlay,
                    onError: (PlacesAutocompleteResponse response) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text(response.errorMessage)),
                      );
                    },
                    language: "en");

                if (prediction == null) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text("Unsuccessful search")),
                  );
                }

                var placeId = prediction.placeId;
                var details = await _places.getDetailsByPlaceId(placeId);
                _inputLat = details.result.geometry.location.lat;
                _inputLong = details.result.geometry.location.lng;
                var destinationName =
                    details.result.addressComponents[0].longName;
                _locatorBloc.add(NewTargetCoords(_inputLat, _inputLong,
                    name: destinationName));
              }, textColor: Colors.white),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.03),
              child: TextIndicator(
                  'Latitude: ${goingToRestore ? getStringCoord(_inputLat) : ""}'),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.015),
              child: TextIndicator(
                  'Longitude: ${goingToRestore? getStringCoord(_inputLong) : ""}'),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.03),
              child: StyledButton('Go!', () {
                if (goingToRestore && (state as DistanceCalculated).distance > 0) {
                  goToFinderScreen((state as DistanceCalculated).distance);
                } else {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'First check if your input correct by pressing button "Find"!'),
                    ),
                  );
                }
              },
                  color: goingToRestore && (state as DistanceCalculated).distance > 0
                      ? Color(BLUE_COLOR_HEX)
                      : Colors.grey,
                  textColor: Colors.white),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.015),
              child: StyledButton('Back :(', () {
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigationEvent.toStartScreen);
                BlocProvider.of<LocatorBloc>(context)
                    .add(ExitScreen());
              }, textColor: Colors.white),
            ),
            Spacer(),
            Container(
              child: TextIndicator(
                  'Distance: ${goingToRestore ? getStringDistance((state as DistanceCalculated).distance) : ""}'),
            )
          ],
        ),
      );
    });
  }

  bool isAbleToRestore(DistanceCalculated state) {
    return state.name != null && state.name != "";
  }

  String getStringDistance(distance) {
    distance = distance / 1000;

    if (distance == DISTANCE_INIT) {
      return "";
    }

    if (distance == DISTANCE_ERROR) {
      return "Calculation error! Looks like coordinates are incorrect";
    }

    return distance.toString() + " kms";
  }

  String getStringCoord(coord) {
    if (coord == COORD_INIT) {
      return "";
    } else
      return coord.toString();
  }

  void goToFinderScreen(distance) {
    BlocProvider.of<NavigationBloc>(context)
        .add(NavigationEvent.toFinderScreenAdd);
  }
}
