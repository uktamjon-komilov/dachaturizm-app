import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/restartable_app.dart';
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
    {"code": "ru", "language": "Русский"},
    {"code": "en", "language": "English"},
  ];

  String chosenLang = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavigationalAppBar(
        context,
        Locales.string(context, "change_language"),
        () {},
        [
          chosenLang != ""
              ? IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    changeLocale(context, chosenLang);
                    Provider.of<NavigationScreenProvider>(context,
                            listen: false)
                        .refreshHomePage = true;
                    RestartWidget.restartApp(context);
                    Navigator.of(context).pop({"change": true});
                  },
                )
              : Container()
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) => Container(
                child: InkWell(
                  onTap: () {
                    chosenLang = languages[index]["code"] as String;
                    changeLocale(context, chosenLang);
                    setState(() {});
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
    );
  }
}
