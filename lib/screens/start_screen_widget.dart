import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_state/native_state.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatefulWidget {
  @override
  State createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    SharedPreferences.getInstance().then((instance) {
      String screenString = instance.getString(SCREEN_KEY);
      NavigationEvent navigationEvent;
      var bloc = BlocProvider.of<NavigationBloc>(context);
      switch (screenString) {
        case SCREEN_START:
          navigationEvent = NavigationEvent.toStartScreen;
          break;
        case SCREEN_ADDRESS:
          navigationEvent = NavigationEvent.toAddressesScreen;
          break;
        case SCREEN_COORD:
          navigationEvent = NavigationEvent.toCoordinatesScreen;
          break;
        case SCREEN_FINDER_ADD:
          navigationEvent = NavigationEvent.toFinderScreenAdd;
          break;
//        case SCREEN_FINDER_COORD:
//          if (instance.getDouble(FINDER_SCREEN_LAT) != COORD_ERROR) {
//            bloc.locator.setTargetPosition(
//                instance.getDouble(FINDER_SCREEN_LAT),
//                instance.getDouble(FINDER_SCREEN_LONG));
//          }
//          navigationEvent = NavigationEvent.toFinderScreenCoord;
//          break;
        default:
          instance.setString(SCREEN_KEY, SCREEN_START);
      }

      bloc.add(navigationEvent);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
            vertical: height * 0.2, horizontal: width * 0.1),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: height * 0.03),
              child: StyledButton(
                'Navigate to coordinates',
                () {
                  BlocProvider.of<NavigationBloc>(context)
                      .add(NavigationEvent.toCoordinatesScreen);
                },
                textColor: Colors.white,
              ),
            ),
            Container(
              child: StyledButton('Navigate to address', () {
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigationEvent.toAddressesScreen);
              }, textColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
