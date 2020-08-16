import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/commons/locator.dart';
import 'package:pelengator/screens/finder/labels.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinderScreen extends StatefulWidget {
  final bool byAddress;

  FinderScreen(this.byAddress);

  @override
  State createState() => FinderScreenState();
}

class FinderScreenState extends State<FinderScreen>
    with SingleTickerProviderStateMixin {
  Locator _locator;

  Color backgroundColor = Colors.white;

  int _blinkFrequency = 0;
  AnimationController _animationController;

  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    initBlinkerController();

    _locator = BlocProvider.of<NavigationBloc>(context).locator;
    _locator.initCompass(updateViewAngle);
    _locator.initRangeFinder(updateViewRange);
    SharedPreferences.getInstance().then((instance) {
      sharedPreferences = instance;
//
//      if (widget.byAddress)
//        sharedPreferences.setString(SCREEN_KEY, SCREEN_FINDER_ADD);
//      else
//        sharedPreferences.setString(SCREEN_KEY, SCREEN_FINDER_COORD);
//
    });
  }

  void initBlinkerController() {
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat();
  }

  void changeBlinkDuration() {
    if (_blinkFrequency != 0) {
      _animationController.duration =
          Duration(milliseconds: (1000 / _blinkFrequency).round());
      if (_animationController.isAnimating) {
        _animationController.repeat();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    changeBlinkDuration();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: backgroundColor,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child:
                _locator != null && _locator.turnDirection == TurnDirection.left
                    ? FadeTransition(
                        opacity: _animationController,
                        child: getLeftLabel(width, height),
                      )
                    : getLeftLabel(width, height),
          ),
          Align(
            alignment: Alignment.topRight,
            child: _locator != null &&
                    _locator.turnDirection == TurnDirection.right
                ? FadeTransition(
                    opacity: _animationController,
                    child: getRightLabel(width, height))
                : getRightLabel(width, height),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(50.0),
              child: TextIndicator(
                _locator == null
                    ? 'Distance:'
                    : 'Distance: ${getDistanceString()}',
                width: width * 0.5,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: height * 0.02),
                    child: StyledButton(
                      'Back',
                      () {
//                        sharedPreferences.remove(FINDER_SCREEN_LAT);
//                        sharedPreferences.remove(FINDER_SCREEN_LONG);
                        sharedPreferences.remove(SCREEN_KEY);
                        _locator.reset();
                        BlocProvider.of<NavigationBloc>(context).add(
                            widget.byAddress
                                ? NavigationEvent.toAddressesScreen
                                : NavigationEvent.toCoordinatesScreen);
                      },
                      color: Colors.transparent,
                      textColor: Color(BLUE_COLOR_HEX),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: height * 0.06),
                    child: StyledButton(
                      'Drop',
                      () {
//                        sharedPreferences.remove(FINDER_SCREEN_LAT);
//                        sharedPreferences.remove(FINDER_SCREEN_LONG);
                        sharedPreferences.remove(SCREEN_KEY);
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigationEvent.toStartScreen);
                        _locator.reset();
                      },
                      color: Colors.transparent,
                      textColor: Color(BLUE_COLOR_HEX),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updateViewRange() {
    var color;
    if (_locator.distance > 50) {
      color = Colors.white;
    } else if (_locator.distance < 50 && _locator.distance > 10) {
      color = Colors.yellow;
    } else {
      color = Colors.green;
    }

    setState(() {
      backgroundColor = color;
    });
  }

  void updateViewAngle() {
    setState(() {
      if (_locator.angleBetween > 45) {
        _blinkFrequency = 2;
      }
      if (_locator.angleBetween > 90) {
        _blinkFrequency = 5;
      }
    });
  }

  String getDistanceString() {
    return _locator.distance.round().toString() + " meters";
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
