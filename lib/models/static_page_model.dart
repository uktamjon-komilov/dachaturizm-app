import 'package:dachaturizm/helpers/locale_helper.dart';

class StaticPageModel {
  final int id;
  final String title;
  final String slug;
  final String content;

  StaticPageModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
  });

  static Future<StaticPageModel> fromJson(data) async {
    String locale = await getCurrentLocale();
    return StaticPageModel(
      id: data["id"],
      title: data["translations"][locale]["title"],
      content: data["translations"][locale]["content"],
      slug: data["slug"],
    );
  }
}
