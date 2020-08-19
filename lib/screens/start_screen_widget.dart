import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/top_level_blocs/locator_bloc.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';

class StartScreen extends StatefulWidget {
  @override
  State createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return BlocBuilder<LocatorBloc, LocatorState>(builder: (context, state) {
      if (state is AppStateRestored) {
        if (state.navigationState != null &&
            state.navigationState != NavigationState.start) {
          var event;
          switch (state.navigationState) {
            case NavigationState.coordinates:
              event = NavigationEvent.toCoordinatesScreen;
              break;
            case NavigationState.addresses:
              event = NavigationEvent.toAddressesScreen;
              break;
            case NavigationState.finderAddress:
              event = NavigationEvent.toFinderScreenAdd;
              break;
            case NavigationState.finderCoordinates:
              event = NavigationEvent.toFinderScreenCoord;
              break;
          }
          BlocProvider.of<NavigationBloc>(context).add(event);
        }
      }

      return FutureBuilder(
        future: BlocProvider.of<LocatorBloc>(context).getPreferences(),
        builder: (context, snap) {
          if (snap.hasData) {
            BlocProvider.of<LocatorBloc>(context).add(RestoreState());
          }
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
        },
      );
    });
  }
}
