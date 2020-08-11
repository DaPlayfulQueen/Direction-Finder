import 'package:flutter/material.dart';

class StyledTextfield extends StatelessWidget {
  final String _text;

  StyledTextfield(this._text);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration:
          InputDecoration(border: OutlineInputBorder(), hintText: _text),
    );
  }
}
