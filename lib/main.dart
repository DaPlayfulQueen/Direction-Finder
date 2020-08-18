import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pelengator/screens/address_screen_widget.dart';
import 'package:pelengator/screens/coordscreen_widget.dart';
import 'package:pelengator/screens/finder/finder_widget.dart';
import 'package:pelengator/top_level_blocs/locator_bloc.dart';
import 'package:pelengator/screens/start_screen_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';


void main() async {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<NavigationBloc>(create: (context) {
          return NavigationBloc(NavigationState.start);
        }),
        BlocProvider<LocatorBloc>(create: (context) {
          return LocatorBloc();
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
      navigatorKey: GlobalKey(),
      debugShowCheckedModeBanner: false,
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
