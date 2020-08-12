import 'package:flutter/material.dart';
import 'package:pelengator/coord_screen/coordscreen_bloc.dart';
import 'package:pelengator/coord_screen/coordscreen_widget.dart';
import 'package:pelengator/finder_screen/finder_screen_widget.dart';
import 'package:pelengator/start_screen/start_screen_widget.dart';

import 'address_screen/address_screen_widget.dart';
import 'common_utils/locator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final Locator locator = Locator();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => StartScreen(locator),
        '/coord_screen': (context) => CoordScreen(),
        '/address_screen': (context) => AddressScreen(),
        '/finder_screen': (context) => FinderScreen()
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
