import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/locale_helper.dart';

class TypeModel {
  final int id;
  final String title;
  final String slug;
  final String foregroundColor;
  final String backgroundColor;
  final String icon;

  TypeModel(
      {required this.id,
      required this.title,
      required this.slug,
      required this.icon,
      required this.foregroundColor,
      required this.backgroundColor});

  static Future<TypeModel> fromJson(data) async {
    String locale = await getCurrentLocale();

    final icon;
    if (data["icon"].runtimeType == Null) {
      icon = "";
    } else {
      icon = baseUrl + data["icon"];
    }

    return TypeModel(
      id: data["id"],
      title: data["translations"][locale]["title"],
      slug: data["slug"],
      icon: icon,
      backgroundColor: data["background_color"],
      foregroundColor: data["foreground_color"],
    );
  }
}
