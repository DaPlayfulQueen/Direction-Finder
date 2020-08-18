//import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_google_places/flutter_google_places.dart';
//import 'package:geolocator/geolocator.dart';
//import 'package:pelengator/common_widgets/button.dart';
//import 'package:pelengator/common_widgets/textindicator.dart';
//import 'package:pelengator/commons/consts.dart';
//import 'package:pelengator/commons/locator.dart';
//import 'package:pelengator/top_level_blocs/navigation_bloc.dart';
//import 'package:google_maps_webservice/places.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//
//class AddressScreen extends StatefulWidget {
//  AddressScreen();
//
//  @override
//  State createState() => AddressScreenState();
//}
//
//class AddressScreenState extends State<AddressScreen> {
//  final _formKey = GlobalKey<FormState>();
//
//  double _tempDistance = DISTANCE_INIT;
//  double _tempDestinationLat = COORD_INIT;
//  double _tempDestinationLong = COORD_INIT;
//
//  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: API_KEY);
//
//  String _placeName = "";
//
//  Locator _locator;
//
//  TextEditingController _controller = TextEditingController();
//
//  SharedPreferences sharedPreferences;
//
//  @override
//  void initState() {
//    SharedPreferences.getInstance().then((instance) {
//      sharedPreferences = instance;
//      sharedPreferences.setString(SCREEN_KEY, SCREEN_ADDRESS);
//      if (sharedPreferences.getString(ADD_SCREEN_ADDRESS) != null) {
//        setState(() {
//          _placeName = sharedPreferences.getString(ADD_SCREEN_ADDRESS);
//          _controller.text = _placeName;
//          _tempDistance = sharedPreferences.getDouble(ADD_SCREEN_DISTANCE);
//          _tempDestinationLat = sharedPreferences.getDouble(ADD_SCREEN_LAT);
//          _tempDestinationLong = sharedPreferences.getDouble(ADD_SCREEN_LONG);
//        });
//      }
//    });
//    super.initState();
////    _locator = BlocProvider.of<NavigationBloc>(context).locator;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    double height = MediaQuery.of(context).size.height;
//    double width = MediaQuery.of(context).size.width;
//    return Container(
//      width: double.infinity,
//      margin:
//          EdgeInsets.symmetric(vertical: height * 0.1, horizontal: width * 0.1),
//      child: Column(
//        children: <Widget>[
//          Container(
//              child: Form(
//            key: _formKey,
//            child: TextFormField(
//              controller: _controller,
////              validator: (value) {
////                if (value.isEmpty) {
////                  return "Fill this field";
////                }
////                return null;
////              },
//              decoration: InputDecoration(
//                  border: OutlineInputBorder(), hintText: 'Address'),
//            ),
//          )),
//          Container(
//            margin: EdgeInsets.only(top: height * 0.03),
//            child: StyledButton('Find', () async {
////              if (_formKey.currentState.validate()) {
//                Prediction prediction = await PlacesAutocomplete.show(
//                    context: context,
//                    apiKey: API_KEY,
//                    mode: Mode.overlay,
//                    onError: (PlacesAutocompleteResponse response) {
//                      Scaffold.of(context).showSnackBar(
//                        SnackBar(content: Text(response.errorMessage)),
//                      );
//                    },
//                    language: "en");
//
//                if (prediction == null) {
//                  Scaffold.of(context).showSnackBar(
//                    SnackBar(content: Text("Unsuccessful search")),
//                  );
//                }
//
//                var placeId = prediction.placeId;
//                var details = await _places.getDetailsByPlaceId(placeId);
//                _tempDestinationLat = details.result.geometry.location.lat;
//                _tempDestinationLong = details.result.geometry.location.lng;
//                await calculateDistance();
//                _placeName = details.result.addressComponents[0].longName;
//                _controller.text = _placeName;
//                setState(() {
//                  setPreferences();
//                });
////              }
//            }, textColor: Colors.white),
//          ),
//          Container(
//            margin: EdgeInsets.only(top: height * 0.03),
//            child: TextIndicator('Latitude: ${getLatString()}'),
//          ),
//          Container(
//            margin: EdgeInsets.only(top: height * 0.015),
//            child: TextIndicator('Longitude: ${getLongString()}'),
//          ),
//          Container(
//            margin: EdgeInsets.only(top: height * 0.03),
//            child: StyledButton('Go!', goCallback,
//                color: _tempDistance < 0 ? Colors.grey : Color(BLUE_COLOR_HEX),
//                textColor: Colors.white),
//          ),
//          Container(
//            margin: EdgeInsets.only(top: height * 0.015),
//            child: StyledButton('Back :(', () {
//              sharedPreferences.remove(SCREEN_KEY);
//              BlocProvider.of<NavigationBloc>(context)
//                  .add(NavigationEvent.toStartScreen);
//            }, textColor: Colors.white),
//          ),
//          Spacer(),
//          Container(
//            child: TextIndicator('Distance: ${getDistanceString()}'),
//          )
//        ],
//      ),
//    );
//  }
//
//  Future<void> calculateDistance() async {
//    Position userPosition = await _locator.getUserPositionOnce();
//    _tempDistance = (await _locator.calculateDistance(
//            userPosition,
//            Position(
//                latitude: _tempDestinationLat,
//                longitude: _tempDestinationLong))) /
//        1000;
//  }
//
//  String getDistanceString() {
//    if (_tempDistance == DISTANCE_INIT) {
//      return "";
//    }
//    return _tempDistance.toString() + " kms";
//  }
//
//  String getLatString() {
//    if (_tempDestinationLat == COORD_INIT) {
//      return "";
//    } else
//      return _tempDestinationLat.toString();
//  }
//
//  String getLongString() {
//    if (_tempDestinationLong == COORD_INIT) {
//      return "";
//    } else
//      return _tempDestinationLong.toString();
//  }
//
//  void goCallback() {
//    if (_tempDistance == DISTANCE_INIT) {
//      Scaffold.of(context).showSnackBar(
//        SnackBar(
//          content: Text(
//              'First find a place to go and validate it by pressing "Find"!'),
//        ),
//      );
//    } else {
//      _locator.setTargetPosition(_tempDestinationLat, _tempDestinationLong);
//      _locator.setInitialDistanceToPosition(_tempDistance);
//      BlocProvider.of<NavigationBloc>(context)
//          .add(NavigationEvent.toFinderScreenAdd);
//    }
//  }
//
//  void setPreferences() {
//    sharedPreferences.setDouble(ADD_SCREEN_LAT, _tempDestinationLat);
//    sharedPreferences.setDouble(ADD_SCREEN_LONG, _tempDestinationLong);
//    sharedPreferences.setDouble(ADD_SCREEN_DISTANCE, _tempDistance);
//    sharedPreferences.setString(ADD_SCREEN_ADDRESS, _placeName);
//  }
//}
