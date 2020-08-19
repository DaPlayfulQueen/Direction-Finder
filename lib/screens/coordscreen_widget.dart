import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/top_level_blocs/locator_bloc.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';

class CoordScreen extends StatefulWidget {
  CoordScreen();

  @override
  State createState() => CoordScreenState();
}

class CoordScreenState extends State<CoordScreen> {
  final _formKey = GlobalKey<FormState>();

  LocatorBloc _locatorBloc;

  double _inputLat;
  double _inputLong;

  @override
  void initState() {
    _locatorBloc = BlocProvider.of<LocatorBloc>(context);
    super.initState();
  }

  _onFieldsValidated() async {
    if (_formKey.currentState.validate()) {
      _locatorBloc.add(NewTargetCoords(_inputLat, _inputLong));
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return BlocBuilder<LocatorBloc, LocatorState>(
      builder: (context, state) => Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
            vertical: height * 0.1, horizontal: width * 0.1),
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
                        _inputLat = parsed;
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
                        _inputLong = parsed;
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
                textColor: Colors.white,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: height * 0.05),
              child: StyledButton(
                'Go!',
                () {
                  if (state is DestinationCoordsSet && state.distance > 0) {
                    goToFinderScreen(state.distance);
                  } else {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'First check if your input correct by pressing button "Find"!'),
                      ),
                    );
                  }
                },
                color: state is StartListenUserPosition
                    ? Colors.grey
                    : Color(BLUE_COLOR_HEX),
                textColor: Colors.white,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: height * 0.05),
              child: StyledButton(
                'Back :(',
                returnToStartScreen,
                textColor: Colors.white,
              ),
            ),
            Spacer(),
            Container(
              child: TextIndicator('Distance: ${getDistanceString(state)}'),
            ),
          ],
        ),
      ),
    );
  }

  String getDistanceString(state) {
    double distance;

    if (!(state is DestinationCoordsSet)) {
      return "";
    }
    if (distance == DISTANCE_INIT) {
      return "";
    }

    if (distance == DISTANCE_ERROR) {
      return "Calculation error! Looks like coordinates are incorrect";
    }

    distance = state.distance / 1000;
    return distance.toString() + " kms";
  }

  void goToFinderScreen(double distance) {
    BlocProvider.of<NavigationBloc>(context)
        .add(NavigationEvent.toFinderScreenCoord);
  }

  returnToStartScreen() {
    BlocProvider.of<NavigationBloc>(context).add(NavigationEvent.toStartScreen);
  }
}
