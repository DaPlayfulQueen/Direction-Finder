import 'package:flutter/material.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/commons/locator.dart';
import 'package:pelengator/screens/address_screen_widget.dart';
import 'package:pelengator/screens/coordscreen_widget.dart';
import 'package:pelengator/screens/finder_screen_widget.dart';
import 'package:pelengator/screens/start_screen_widget.dart';



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
      home: FinderScreen(Locator()),
    );
  }
}

//class AppWrapper extends StatefulWidget {
//  @override
//  State createState() => AppWrapperState();
//}
//
//class AppWrapperState extends State<AppWrapper> {
//  final Locator locator = Locator();
//  Screens currentScreen = Screens.finder;
//
//
//
//
//  @override
//  Widget build(BuildContext context) {
//    var currentScreenWidget;
//
//    switch (currentScreen) {
//      case Screens.start:
//        currentScreenWidget = StartScreen(changeAppScreen);
//        break;
//      case Screens.coordinates:
//        currentScreenWidget = CoordScreen(changeAppScreen, locator);
//        break;
//      case Screens.addresses:
//        currentScreenWidget = AddressScreen(locator);
//        break;
//        currentScreenWidget = FinderScreen(locator);
//    }
//
//    return Scaffold(
//      body: Builder(
//        builder: (context) => currentScreenWidget,
//      ),
//    );
//  }
//
//  void changeAppScreen(Screens screen) {
//    setState(() {
//      currentScreen = screen;
//    });
//  }
//
//
//
//}
