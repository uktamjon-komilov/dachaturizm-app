import 'package:dachaturizm/screens/auth/auth_type_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class OnBoardLoading extends StatefulWidget {
  const OnBoardLoading({Key? key}) : super(key: key);

  @override
  _OnBoardLoadingState createState() => _OnBoardLoadingState();
}

class _OnBoardLoadingState extends State<OnBoardLoading> {

  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => AuthType()
      )
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/logo.png",
          scale: 2.0,
        ),
      ),
    );
  }
}
