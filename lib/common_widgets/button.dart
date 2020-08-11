import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  String _text;
  Function _callback;
  double _height;
  double _width;

  StyledButton(this._text, this._callback, this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      child: RaisedButton(
        color: Colors.blueAccent,
        child: Text(
          _text,
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        onPressed: _callback,
      ),
    );
  }
}
