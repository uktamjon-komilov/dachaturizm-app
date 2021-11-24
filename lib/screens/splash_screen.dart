import 'package:dachaturizm/screens/app/home_screen.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/loading/choose_language_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var first_time = prefs.getBool("first_time");

    var _duration = new Duration(seconds: 3);

    if (first_time != null && first_time == false) {
      String language = prefs.getString("language") as String;
      Locales.change(context, language);
      return new Timer(_duration, navigationNavigationalScreen);
    } else {
      return new Timer(_duration, navigationChooseLanguageScreen);
    }
  }

  void navigationNavigationalScreen() {
    Navigator.of(context).pushReplacementNamed(NavigationalAppScreen.routeName);
  }

  void navigationChooseLanguageScreen() {
    Navigator.of(context).pushReplacementNamed(ChooseLangugageScreen.routeName);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Center(
            child: Image.asset(
              "assets/images/logo.png",
              scale: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}
