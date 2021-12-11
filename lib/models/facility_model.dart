import 'package:dachaturizm/helpers/locale_helper.dart';

class FacilityModel {
  final int id;
  final String title;

  FacilityModel({required this.id, required this.title});

  static Future<FacilityModel> fromJson(data) async {
    String locale = await getCurrentLocale();

    return FacilityModel(
      id: data["id"],
      title: data["translations"][locale]["title"],
    );
  }
}
