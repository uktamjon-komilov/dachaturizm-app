import 'dart:async';
import 'dart:io';

import 'package:dachaturizm/screens/locale_helper.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  static String routeName = "/change-password";

  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  final List<Map<String, String>> languages = [
    {"code": "uz", "language": "O'zbekcha"},
    {"code": "ru", "language": "Russkiy"},
    {"code": "en", "language": "English"},
  ];

  String chosenLang = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: LocaleText("change_language"),
          leading: chosenLang == ""
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              : Container(),
          actions: [
            chosenLang != ""
                ? IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      changeLocale(context, chosenLang);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: LocaleText("restart_the_app"),
                        ),
                      );
                      Future.delayed(Duration(seconds: 4)).then((_) => exit(0));
                    },
                  )
                : Container()
          ],
        ),
        body: ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) => Container(
            child: InkWell(
              onTap: () {
                chosenLang = languages[index]["code"] as String;
                changeLocale(context, chosenLang);
              },
              child: ListTile(
                title: Text(
                  languages[index]["language"].toString(),
                  style: TextStyle(
                    fontWeight: languages[index]["code"] == chosenLang
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                leading: Image.asset(
                    "assets/images/flag_${languages[index]["code"]}.png"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
