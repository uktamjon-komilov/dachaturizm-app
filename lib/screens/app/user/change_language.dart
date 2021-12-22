import 'dart:async';
import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/banner_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/type_provider.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  static String routeName = "/change-password";

  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  bool _isLoading = false;

  final List<Map<String, String>> languages = [
    {"code": "uz", "language": "O'zbekcha"},
    {"code": "ru", "language": "Russkiy"},
    {"code": "en", "language": "English"},
  ];

  String chosenLang = "";

  Future _refreshAll() async {
    setState(() {
      _isLoading = true;
    });
    Provider.of<BannerProvider>(context, listen: false)
        .getAndSetTopBanners()
        .then((_) {
      Provider.of<EstateTypesProvider>(context, listen: false)
          .fetchAndSetTypes()
          .then(
        (types) {
          Provider.of<BannerProvider>(context, listen: false)
              .getAndSetBanners(types)
              .then((banners) {
            Provider.of<EstateProvider>(context, listen: false)
                .fetchAllAndSetEstates()
                .then((_) {
              Provider.of<AuthProvider>(context).getUserData().then((_) {
                setState(() {
                  _isLoading = false;
                });
              });
            });
          });
        },
      );
    });
  }

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
                    onPressed: () async {
                      changeLocale(context, chosenLang);
                      await _refreshAll();
                      Navigator.of(context).pop();
                    },
                  )
                : Container()
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
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
