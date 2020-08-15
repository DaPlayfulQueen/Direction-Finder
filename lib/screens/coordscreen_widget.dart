import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/commons/locator.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';

class CoordScreen extends StatefulWidget {
  CoordScreen();

  @override
  State createState() => CoordScreenState();
}

class CoordScreenState extends State<CoordScreen> {
  final _formKey = GlobalKey<FormState>();

  Locator _locator;

  double tempDistance = DISTANCE_INIT;
  double tempDestinationLat;
  double tempDestinationLong;

  @override
  void initState() {
    super.initState();
    _locator = BlocProvider.of<NavigationBloc>(context).locator;
  }

  _onFieldsValidated() async {
    if (_formKey.currentState.validate()) {
      await getDistanceToPoint();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      margin:
          EdgeInsets.symmetric(vertical: height * 0.1, horizontal: width * 0.1),
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: height * 0.05),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Fill this field';
                      }
                      var parsed = double.tryParse(value);
                      if (parsed == null) {
                        return "It's not a number";
                      }
                      tempDestinationLat = parsed;
                      return null;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Latitude'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: height * 0.05),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Fill this field';
                      }
                      var parsed = double.tryParse(value);
                      if (parsed == null) {
                        return "It's not a number";
                      }
                      tempDestinationLong = parsed;
                      return null;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Longitude'),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: height * 0.025),
            child: StyledButton(
              'Find',
              _onFieldsValidated,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: height * 0.05),
            child: StyledButton('Go!', goCallback,
                color: tempDistance < 0 ? Colors.grey : Color(BLUE_COLOR_HEX)),
          ),
          Container(
            margin: EdgeInsets.only(bottom: height * 0.05),
            child: StyledButton('Back :(', backCallback),
          ),
          Spacer(),
          Container(
            child: TextIndicator('Distance: ${getDistanceString()}'),
          ),
        ],
      ),
    );
  }

  getDistanceToPoint() async {
    Position userPosition = await _locator.getUserPositionOnce();
    tempDistance = (await _locator.calculateDistance(
            userPosition,
            Position(
                latitude: tempDestinationLat,
                longitude: tempDestinationLong))) /
        1000;
  }

  String getDistanceString() {
    if (tempDistance == DISTANCE_INIT) {
      return "";
    }

    if (tempDistance == DISTANCE_ERROR) {
      return "Calculation error! Looks like coordinates are incorrect";
    }

    return tempDistance.toString() + " kms";
  }

  goCallback() {
    if (tempDistance == DISTANCE_INIT || tempDistance == DISTANCE_ERROR) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'First check if your input correct by pressing button "Find"!'),
        ),
      );
    } else {
      _locator.setTargetPosition(tempDestinationLat, tempDestinationLong);
      _locator.setInitialDistanceToPosition(tempDistance);
      BlocProvider.of<NavigationBloc>(context)
          .add(NavigationEvent.toFinderScreenAdd);
    }
  }

  backCallback() {
    BlocProvider.of<NavigationBloc>(context).add(NavigationEvent.toStartScreen);
  }
}
