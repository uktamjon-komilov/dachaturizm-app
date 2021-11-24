import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/app/home_screen.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/locale_helper.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.12),
                child: Image.asset("assets/images/languages.png"),
              ),
              LocaleText(
                "choose_language",
                style: TextStyle(
                  fontSize: 25,
                  color: darkPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Column(
                children: [
                  _buildLangitem("uz"),
                  _buildLangitem("ru"),
                  _buildLangitem("en"),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 2,
                ),
                child: FluidBigButton(
                  LocaleText(
                    "next",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPress: () async {
                    if (chosenLang == "") return;
                    changeLocale(context, chosenLang);
                    setNotFirstTime();
                    Navigator.pushNamed(
                        context, NavigationalAppScreen.routeName);
                  },
                  disabled: chosenLang == "",
                ),
              ),
              SizedBox(
                height: 30,
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
        decoration: BoxDecoration(
          color: chosenLang == lang
              ? normalOrange.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/flag_${lang}.png"),
            SizedBox(
              width: 11,
            ),
            Text(
              "${lang}".toUpperCase(),
              style: TextStyle(
                fontSize: 35,
                color: darkPurple,
                fontWeight: FontWeight.w700,
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
