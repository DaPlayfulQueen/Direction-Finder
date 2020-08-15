import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/commons/consts.dart';
import 'package:pelengator/commons/locator.dart';

class CoordScreen extends StatefulWidget {
  final Locator locator;
  final Function changeAppScreen;

  CoordScreen(this.changeAppScreen, this.locator);

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
    setTextfieldControllers();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      margin:
          EdgeInsets.symmetric(vertical: height * 0.1, horizontal: width * 0.1),
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
            child: StyledButton('Go!', goCallback),
          ),
          Container(
            margin: EdgeInsets.only(bottom: height * 0.05),
            child: StyledButton('Back :(', backCallback),
          ),
          Spacer(),
          Container(
            child: TextIndicator('Distance: '),
          ),
        ],
      ),
    );
  }

  void setTextfieldControllers() {
    latController.addListener(() {
      var value = double.tryParse(latController.text);
      print("PARSED IS $value");
      if (value != null) {
        targetLat = value;
        getDistanceToPoint();
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
        getDistanceToPoint();
      } else {
        targetLong = COORD_ERROR;
        distance = DISTANCE_ERROR;
      }
      setState(() {});
    });
  }

  getDistanceToPoint() async {
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

  String getDistanceString() {
    if (distance == DISTANCE_INIT) return "";
    if (distance == DISTANCE_ERROR) return "Could not calculate :(";
    return distance.toString();
  }


  void goCallback() {
    if (distance == DISTANCE_INIT || distance == DISTANCE_ERROR) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Input correct coordinates first!"),
        ),
      );
    } else {
      widget.locator.setTargetPosition(targetLat, targetLong);
      widget.changeAppScreen(Screens.finder);
    }
  }

  backCallback() {
    widget.changeAppScreen(Screens.start);
  }
}
