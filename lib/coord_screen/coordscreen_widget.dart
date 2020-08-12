import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pelengator/common_utils/consts.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:validators/validators.dart';

import '../common_utils/locator.dart';

class CoordScreen extends StatefulWidget {
  final Locator locator;

  CoordScreen(this.locator);

  @override
  State createState() => CoordScreenState();
}

class CoordScreenState extends State<CoordScreen> {
  double distance = DISTANCE_INIT;
  double targetLat = COORD_INIT;
  double targetLong = COORD_INIT;

  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();

  @override
  void initState() {
    super.initState();
    latController.addListener(() {
      var value = double.tryParse(latController.text);
      print("PARSED IS $value");
      if (value != null) {
        targetLat = value;
        getDistanceByCoordinates();
      } else {
        targetLat = COORD_ERROR;
        distance = DISTANCE_ERROR;
      }
      setState(() {});
    });
    longController.addListener(() {
      var value = double.tryParse(longController.text);
      if (value != null) {
        targetLong = value;
        getDistanceByCoordinates();
      } else {
        targetLong = COORD_ERROR;
        distance = DISTANCE_ERROR;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
              vertical: height * 0.1, horizontal: width * 0.1),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: height * 0.05),
                child: TextField(
                  controller: latController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Latitude'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: height * 0.05),
                child: TextField(
                  controller: longController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Longitude'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: height * 0.05),
                child: StyledButton('Go!', () {
                  if (distance == DISTANCE_INIT || distance == DISTANCE_ERROR) {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Input correct coordinates first!"),
                      ),
                    );
                  }
                }, height * 0.08, double.infinity),
              ),
              Container(
                margin: EdgeInsets.only(bottom: height * 0.05),
                child: StyledButton(
                    'Back :(', () async {}, height * 0.08, double.infinity),
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
                      'Distance: ${getDistanceString()}',
                      style: TextStyle(fontSize: 20.0),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
  }

  getDistanceByCoordinates() async {
    if (targetLat == COORD_ERROR || targetLong == COORD_ERROR) {
      distance = DISTANCE_ERROR;
      return;
    }

    if (targetLat == COORD_INIT || targetLong == COORD_INIT) {
      distance = DISTANCE_INIT;
      return;
    }

    Position userPosition = await widget.locator.getUserPositionOnce();
    distance = (await widget.locator.calculateDistanceOnce(
        userPosition, Position(latitude: targetLat, longitude: targetLong)));

    if (distance != DISTANCE_ERROR) {
      distance /= 1000;
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  String getDistanceString() {
    if (distance == DISTANCE_INIT) return "";
    if (distance == DISTANCE_ERROR) return "Could not calculate :(";
    return distance.toString();
  }
}
