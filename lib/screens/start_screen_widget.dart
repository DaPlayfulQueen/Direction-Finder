import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/app_wrapper/app_wrapper_bloc.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/commons/consts.dart';

class StartScreen extends StatelessWidget {
  StartScreen();

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
              child: StyledButton(
                'Navigate to coordinates',
                () {
                  BlocProvider.of<NavigationBloc>(context).add(NavigationEvent.toCoordinatesScreen);
                },
                textColor: Colors.white,
              ),
            ),
            Container(
              child: StyledButton('Navigate to address', () {
                BlocProvider.of<NavigationBloc>(context).add(NavigationEvent.toAddressesScreen);
              }, textColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
