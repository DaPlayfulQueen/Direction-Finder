import 'package:flutter/material.dart';
import 'package:pelengator/address_screen/address_screen_widget.dart';
import 'package:pelengator/coord_screen/coordscreen_widget.dart';
import 'package:pelengator/finder_screen/finder_screen_widget.dart';
import 'package:pelengator/start_screen/start_screen_widget.dart';

import 'commons/consts.dart';
import 'commons/locator.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Direction Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  @override
  State createState() => AppWrapperState();
}

class AppWrapperState extends State<AppWrapper> {
  final Locator locator = Locator();
  Screens currentScreen = Screens.start;

  @override
  Widget build(BuildContext context) {
    var currentScreenWidget;

    switch (currentScreen) {
      case Screens.start:
        currentScreenWidget = StartScreen(changeAppScreen);
        break;
      case Screens.coordinates:
        currentScreenWidget = CoordScreen(changeAppScreen, locator);
        break;
      case Screens.addresses:
        currentScreenWidget = AddressScreen(locator);
        break;
      case Screens.finder:
        currentScreenWidget = FinderScreen(locator);
    }

    return Scaffold(
      body: Builder(
        builder: (context) => currentScreenWidget,
      ),
    );
  }

  void changeAppScreen(Screens screen) {
    setState(() {
      currentScreen = screen;
    });
  }

}
