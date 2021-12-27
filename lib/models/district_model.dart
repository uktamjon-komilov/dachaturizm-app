import 'package:dachaturizm/helpers/locale_helper.dart';

class DistrictModel {
  final int id;
  final String title;
  final Map<String, dynamic> translations;

  DistrictModel(
      {required this.id, required this.title, required this.translations});

  static Future<DistrictModel> fromJson(data) async {
    String locale = await getCurrentLocale();
    print(data);
    return DistrictModel(
      id: data["id"],
      title: data["translations"][locale]["title"],
      translations: data["translations"],
    );
  }

  static Future<List<DistrictModel>> fromJsonBulk(data) async {
    List<DistrictModel> districts = [];
    String locale = await getCurrentLocale();
    await data["districts"].forEach((item) async {
      if (item["translations"].containsKey(locale)) {
        districts.add(await DistrictModel.fromJson(item));
      }
    });
    return districts;
  }
}
