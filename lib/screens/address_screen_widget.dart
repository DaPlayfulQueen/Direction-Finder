import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pelengator/common_widgets/button.dart';
import 'package:pelengator/common_widgets/textindicator.dart';
import 'package:pelengator/top_level_blocs/navigation_bloc.dart';

class AddressScreen extends StatefulWidget {
  AddressScreen();

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
              child: StyledButton('Go!', () {
                BlocProvider.of<NavigationBloc>(context).add(NavigationEvent.toFinderScreenAdd);
              }),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.015),
              child: StyledButton('Back :(', () {
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigationEvent.toStartScreen);
              }),
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
