import 'package:flutter/material.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:location/location.dart';

class CoordScreen extends StatefulWidget {
  @override
  State createState() => CoordScreenState();
}

class CoordScreenState extends State<CoordScreen> {
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
              margin: EdgeInsets.only(bottom: height * 0.05),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Latitude'),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: height * 0.05),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Longitude'),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: height * 0.05),
              child: StyledButton('Go!', () {}, height * 0.08, double.infinity),
            ),
            Container(
              margin: EdgeInsets.only(bottom: height * 0.05),
              child: StyledButton(
                  'Back :(!', () {}, height * 0.08, double.infinity),
            ),
            Spacer(),
            Container(
              width: width * double.infinity,
              height: height * 0.1,
              padding: EdgeInsets.only(left: 20.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.grey, width: 3.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distance: ',
                    style: TextStyle(fontSize: 20.0),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
