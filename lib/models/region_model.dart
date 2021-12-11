import 'package:dachaturizm/helpers/locale_helper.dart';

class RegionModel {
  final int id;
  final String title;

  RegionModel({required this.id, required this.title});

  static Future<RegionModel> fromJson(data) async {
    String locale = await getCurrentLocale();
    return RegionModel(
      id: data["id"],
      title: data["translations"][locale]["title"],
    );
  }
}
