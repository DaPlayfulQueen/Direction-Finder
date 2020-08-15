import 'package:flutter/material.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/commons/locator.dart';

class AddressScreen extends StatefulWidget {
  final Locator locator;

  AddressScreen(this.locator);

  @override
  State createState() => AddressScreenState();
}

class AddressScreenState extends State<AddressScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
            vertical: height * 0.1, horizontal: width * 0.1),
        child: Column(
          children: <Widget>[
            Container(
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Address'),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.03),
              child: StyledButton('Find', () {}),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.03),
              child: TextIndicator('Latitude: '),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.015),
              child: TextIndicator('Longitude: '),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.03),
              child: StyledButton('Go!', () {}),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.015),
              child: StyledButton('Back :(', () {}),
            ),
            Spacer(),
            Container(
              child: TextIndicator('Distance: '),
            )
          ],
        ),
      ),
    );
  }
}
