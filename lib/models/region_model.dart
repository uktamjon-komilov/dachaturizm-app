import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/models/district_model.dart';

class RegionModel {
  final int id;
  final String title;
  final Map<String, dynamic> translations;
  final List<DistrictModel> districts;

  RegionModel({
    required this.id,
    required this.title,
    required this.translations,
    required this.districts,
  });

  static Future<RegionModel> fromJson(data) async {
    String locale = await getCurrentLocale();
    List<DistrictModel> districts = await DistrictModel.fromJsonBulk(data);
    return RegionModel(
      id: data["id"],
      title: data["translations"][locale]["title"],
      translations: data["translations"],
      districts: districts,
    );
  }
}
