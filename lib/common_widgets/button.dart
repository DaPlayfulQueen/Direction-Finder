import 'package:flutter/material.dart';
import 'package:pelengator/commons/consts.dart';

class StyledButton extends StatelessWidget {
  final String _text;
  final Function _callback;
  final Color color;
  final Color textColor;

  StyledButton(this._text, this._callback,
      {this.color = const Color(BLUE_COLOR_HEX), this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
      height: height * 0.08,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Color(BLUE_COLOR_HEX), width: 1.0)),
      child: FlatButton(
        color: color,
        child: Text(
          _text,
          style: TextStyle(color: textColor, fontSize: 20.0, fontWeight: FontWeight.w400),
        ),
        onPressed: _callback,
      ),
    );
  }
}
