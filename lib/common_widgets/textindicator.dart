import 'package:flutter/material.dart';

class TextIndicator extends StatelessWidget {
  final String text;
  final Color color;
  final double width;

  TextIndicator(this.text, {this.color = Colors.blueAccent, this.width = 0});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: this.width == 0 ? width * double.infinity : this.width,
      height: height * 0.08,
      padding: EdgeInsets.only(left: 20.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.grey, width: 1.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 20.0),
          )
        ],
      ),
    );
  }
}
