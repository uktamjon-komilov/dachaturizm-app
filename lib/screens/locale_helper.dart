import 'package:flutter_locales/flutter_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

changeLocale(context, locale) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("language", locale);
  Locales.change(context, locale);
}

Future<String> getCurrentLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var locale = prefs.get("language");
  if (locale == null || locale == "") {
    prefs.setString("language", "uz");
  }
  return prefs.get("language") as String;
}
