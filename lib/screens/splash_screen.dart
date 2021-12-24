import 'dart:convert';

import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/auth/auth_type_screen.dart';
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
    var _duration = new Duration(seconds: 1);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final userData = prefs.getString("userData");
    if (userData != null) {
      final data = json.decode(userData);
      if (data.containsKey("access")) {
        return new Timer(_duration, navigationNavigationalScreen);
      }
    }

    var language = prefs.getString("language");

    if (language == null || language == "") {
      return new Timer(_duration, navigationChooseLanguageScreen);
    } else {
      Locales.change(context, language);
    }

    var noAuth = prefs.getBool("noAuth");
    if (noAuth != null && noAuth == true) {
      return new Timer(_duration, navigationNavigationalScreen);
    } else {
      return new Timer(_duration, navigationAuthTypeScreen);
    }
  }

  void navigationNavigationalScreen() {
    Navigator.of(context).pushReplacementNamed(NavigationalAppScreen.routeName);
  }

  void navigationAuthTypeScreen() {
    Navigator.of(context).pushReplacementNamed(AuthTypeScreen.routeName);
  }

  void navigationChooseLanguageScreen() {
    Navigator.of(context).pushReplacementNamed(ChooseLangugageScreen.routeName);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      startTime();
    });
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
