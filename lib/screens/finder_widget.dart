import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/top_level_blocs/locator_bloc.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';

class FinderScreen extends StatefulWidget {
  final bool byAddress;

  FinderScreen(this.byAddress);

  @override
  State createState() => FinderScreenState();
}

class FinderScreenState extends State<FinderScreen>
    with SingleTickerProviderStateMixin {
  LocatorBloc _locatorBloc;

  Color backgroundColor = Colors.white;

  int _blinkFrequency = 0;
  AnimationController _animationController;

  @override
  void initState() {
    _locatorBloc = BlocProvider.of<LocatorBloc>(context);
    _locatorBloc.add(StartListenUserPosition());
    super.initState();
    initBlinkerController();
  }

  void initBlinkerController() {
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat();
  }

  void changeBlinkDuration(angle) {
    updateBlinkFrequency(angle);
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return BlocBuilder<LocatorBloc, LocatorState>(
      builder: (context, state) => StreamBuilder(
        stream: _locatorBloc.compassStream,
        builder: (context, compassChangeSnapshot) {
          if (compassChangeSnapshot.data != null) {
            changeBlinkDuration(compassChangeSnapshot.data.angle);
          }
          return StreamBuilder(
            stream:  _locatorBloc.positionStream,
            builder: (context, positionChangeSnapshot) {
              return Container(
                color: positionChangeSnapshot.data == null
                    ? Colors.white
                    : getBackgroundColor(positionChangeSnapshot.data.distance),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: compassChangeSnapshot.data != null &&
                          compassChangeSnapshot.data.turnDirection == TurnDirection.left
                          ? FadeTransition(
                        opacity: _animationController,
                        child: getLeftLabel(width, height),
                      )
                          : getLeftLabel(width, height),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: compassChangeSnapshot.data != null &&
                          compassChangeSnapshot.data.turnDirection == TurnDirection.right
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
                          positionChangeSnapshot.data == null
                              ? 'Distance:'
                              : 'Distance: ${positionChangeSnapshot.data.distance}',
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
                                  _locatorBloc.add(StopListenUserPosition());
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
                                  _locatorBloc.add(StopListenUserPosition());
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
            },
          );
        },
      ),
    );
  }

  Color getBackgroundColor(distance) {
    var color;
    if (distance > 50) {
      color = Colors.white;
    } else if (distance < 50 && distance > 10) {
      color = Colors.yellow;
    } else {
      color = Colors.green;
    }

    return color;
  }

  void updateBlinkFrequency(angle) {
    if (angle > 45) {
      _blinkFrequency = 2;
    }
    if (angle > 90) {
      _blinkFrequency = 5;
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget getLeftLabel(width, height) => Container(
        width: width * 0.25,
        margin: EdgeInsets.fromLTRB(width * 0.05, height * 0.1, 0, 0),
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: height * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Left',
              style: TextStyle(fontSize: 20, color: Color(BLUE_COLOR_HEX)),
            ),
          ],
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Color(BLUE_COLOR_HEX), width: 1.0)),
      );

  Widget getRightLabel(width, height) => Container(
        width: width * 0.25,
        margin: EdgeInsets.fromLTRB(0, height * 0.1, width * 0.05, 0),
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: height * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Right',
              style: TextStyle(fontSize: 20, color: Color(BLUE_COLOR_HEX)),
            ),
          ],
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Color(BLUE_COLOR_HEX), width: 1.0)),
      );
}
