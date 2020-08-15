import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/commons/locator.dart';
import 'package:pelengator/screens/finder/labels.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';

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

  @override
  void initState() {
    initBlinkerController();
    super.initState();
    _locator = BlocProvider.of<NavigationBloc>(context).locator;
    _locator.initCompass(updateViewRange);
    _locator.initRangeFinder(updateViewAngle);
//    updateViewRange();
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
            child: _locator.turnDirection == TurnDirection.left ? FadeTransition(
              opacity: _animationController,
              child: getLeftLabel(width, height),
            ) : getLeftLabel(width, height),
          ),
          Align(
            alignment: Alignment.topRight,
            child: _locator.turnDirection == TurnDirection.right ? FadeTransition(
              opacity: _animationController,
              child: getRightLabel(width, height)
            ) : getRightLabel(width, height),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(50.0),
              child: TextIndicator(
                'Distance: ${getDistanceString()}',
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
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigationEvent.toStartScreen);
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
    return _locator.distance.toString() + " kms";
  }
}
