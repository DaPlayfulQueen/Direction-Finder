import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/commons/locator.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';

class FinderScreen extends StatefulWidget {
  final bool byAddress;

  FinderScreen(this.byAddress);

  @override
  State createState() => FinderScreenState();
}

class FinderScreenState extends State<FinderScreen> {

  Locator _locator;

  @override
  void initState() {
    super.initState();
    _locator = BlocProvider.of<NavigationBloc>(context).locator;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: width * 0.25,
              margin: EdgeInsets.fromLTRB(width * 0.05, height * 0.1, 0, 0),
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Left',
                    style:
                        TextStyle(fontSize: 20, color: Color(BLUE_COLOR_HEX)),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(BLUE_COLOR_HEX), width: 1.0)),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: width * 0.25,
              margin: EdgeInsets.fromLTRB(0, height * 0.1, width * 0.05, 0),
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Right',
                    style:
                        TextStyle(fontSize: 20, color: Color(BLUE_COLOR_HEX)),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(BLUE_COLOR_HEX), width: 1.0)),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextIndicator(
              'Distance: ',
              width: width * 0.4,
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
}
