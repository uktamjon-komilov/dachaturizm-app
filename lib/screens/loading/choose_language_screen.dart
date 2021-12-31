import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/auth/auth_type_screen.dart';
import 'package:dachaturizm/helpers/locale_helper.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class ChooseLangugageScreen extends StatefulWidget {
  const ChooseLangugageScreen({Key? key}) : super(key: key);

  static String routeName = "/choose-lang-first-time";

  @override
  _ChooseLangugageScreenState createState() => _ChooseLangugageScreenState();
}

class _ChooseLangugageScreenState extends State<ChooseLangugageScreen> {
  String chosenLang = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.fromLTRB(defaultPadding, 110, defaultPadding, 0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                child: Image.asset(
                  "assets/images/languages.png",
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 105),
              Text(
                Locales.string(context, "choose_language"),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 36),
              Column(
                children: [
                  _buildLangitem("uz"),
                  SizedBox(height: 8),
                  _buildLangitem("ru"),
                  SizedBox(height: 8),
                  _buildLangitem("en"),
                ],
              ),
              SizedBox(height: 52),
              FluidBigButton(
                Locales.string(context, "next"),
                onPress: () async {
                  if (chosenLang == "") return;
                  changeLocale(context, chosenLang);
                  setNotFirstTime();
                  Navigator.pushReplacementNamed(
                      context, AuthTypeScreen.routeName);
                },
                disabled: chosenLang == "",
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangitem(String lang) {
    return GestureDetector(
      onTap: () {
        setState(() {
          chosenLang = lang;
          changeLocale(context, chosenLang);
        });
      },
      child: Container(
        width: 130,
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: chosenLang == lang ? lightGrey : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/flag_${lang}.png",
              height: 28,
              width: 48,
            ),
            SizedBox(width: 11),
            Text(
              "${lang}".toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                height: 1.22,
                letterSpacing: 0.4,
              ),
            )
          ],
        ),
      ),
    );
  }

  setNotFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("first_time", false);
  }
}
