import 'package:flutter/material.dart';
import 'package:pelengator/common_widgets/button.dart';

class StartScreen extends StatelessWidget {
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
              child: StyledButton('Navigate to coordinates', () {
                Navigator.pushNamed(context, '/coord_screen');
              }, height * 0.08, double.infinity),
            ),
            Container(
              child: StyledButton(
                  'Navigate to address', () {
                Navigator.pushNamed(context, '/address_screen');
              }, height * 0.08, double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
