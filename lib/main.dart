import 'package:flutter/material.dart';
import 'package:pelengator/screens/address_screen_widget.dart';
import 'package:pelengator/screens/coordscreen_widget.dart';
import 'package:pelengator/screens/finder_widget.dart';
import 'commons/locator.dart';
import 'package:pelengator/screens/start_screen_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>(create: (context) {
          Locator locator = Locator();
          return NavigationBloc(NavigationState.start, locator);
        }),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Direction Finder',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (_, state) {
            switch (state) {
              case NavigationState.start:
                return StartScreen();
              case NavigationState.coordinates:
                return CoordScreen();
              case NavigationState.addresses:
                return AddressScreen();
              case NavigationState.finderAddress:
                return FinderScreen(true);
              case NavigationState.finderCoordinates:
                return FinderScreen(false);
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}
