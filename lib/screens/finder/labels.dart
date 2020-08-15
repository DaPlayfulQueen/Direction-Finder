import 'package:flutter/material.dart';
import 'package:pelengator/commons/consts.dart';

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
