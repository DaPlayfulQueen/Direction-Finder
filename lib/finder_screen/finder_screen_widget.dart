import 'package:flutter/material.dart';
import 'package:pelengator/common_utils/locator.dart';

class FinderScreen extends StatefulWidget {


  final Locator locator;

  FinderScreen(this.locator);

  @override
  State createState() => FinderScreenState();
}



class FinderScreenState extends State<FinderScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}