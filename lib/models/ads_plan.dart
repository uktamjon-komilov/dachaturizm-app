import 'package:dachaturizm/helpers/locale_helper.dart';

class AdPlan {
  final int id;
  final String slug;
  final String title;
  final String description;
  final int days;
  final double price;
  final bool available;

  AdPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.slug,
    required this.days,
    required this.price,
    required this.available,
  });

  static Future<AdPlan> fromJson(data) async {
    String locale = await getCurrentLocale();
    return AdPlan(
      id: data["id"],
      title: data["translations"].containsKey(locale)
          ? data["translations"][locale]["title"]
          : "-",
      description: data["translations"].containsKey(locale)
          ? data["translations"][locale]["description"]
          : "-",
      slug: data["slug"],
      days: data["days"],
      price: data["price"],
      available: data["available"],
    );
  }
}
