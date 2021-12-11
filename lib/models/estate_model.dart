import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/models/photo_model.dart';

class EstateModel {
  final int id;
  final String title;
  final String description;
  final String priceType;
  final List<Map<String, dynamic>> bookedDays;
  final List<FacilityModel> facilities;
  final double rating;
  final int views;
  final int userAdsCount;
  final String photo;
  final List<EstatePhotos> photos;
  final int beds;
  final int pool;
  final int people;
  final double weekdayPrice;
  final double weekendPrice;
  final String address;
  final double longtitute;
  final double latitute;
  final String announcer;
  final String phone;
  final int userId;
  final int typeId;
  final bool isTop;

  EstateModel({
    this.title = "",
    this.id = 0,
    this.description = "",
    this.priceType = "",
    this.rating = 0.0,
    this.views = 0,
    this.beds = 0,
    this.pool = 0,
    this.people = 0,
    this.weekdayPrice = 0.0,
    this.weekendPrice = 0.0,
    this.address = "",
    this.announcer = "",
    this.phone = "",
    this.userAdsCount = 0,
    this.photo = "",
    this.userId = 0,
    this.typeId = 0,
    this.longtitute = 0.0,
    this.latitute = 0.0,
    this.photos = const [],
    this.bookedDays = const [],
    this.facilities = const [],
    this.isTop = false,
  });

  dynamic getAttr(String key) => <String, dynamic>{
        "isTop": this.isTop,
      }[key];

  static Future<EstateModel> fromJson(data) async {
    String locale = await getCurrentLocale();

    return EstateModel(
      id: data["id"],
      title: data["translations"][locale]["title"],
      description: data["translations"][locale]["description"],
      priceType: data["price_type"]["translations"][locale]["title"],
      rating: data["rating"],
      views: data["views"],
      beds: data["beds"],
      pool: data["pool"],
      people: data["people"],
      weekdayPrice: data["weekday_price"],
      weekendPrice: data["weekend_price"],
      address: data["address"],
      announcer: data["announcer"],
      phone: data["phone"],
      userAdsCount: data["user_ads_count"],
      photo: fixMediaUrl(data["photo"]),
      photos: data["photos"]
          .map<EstatePhotos>((item) =>
              EstatePhotos(id: item["id"], photo: fixMediaUrl(item["photo"])))
          .toList(),
      facilities: data["facilities"]
          .map<FacilityModel>((item) => FacilityModel(
              id: item["id"], title: item["translations"][locale]["title"]))
          .toList(),
      userId: data["user"],
      typeId: data["estate_type"],
      isTop: data["is_top"],
    );
  }

  static Future<EstateModel> fromJsonAsBanner(data) async {
    String locale = await getCurrentLocale();

    return EstateModel(
      id: data["id"],
      title: data["translations"][locale]["title"],
      description: data["translations"][locale]["description"],
      priceType: data["price_type"]["translations"][locale]["title"],
      weekdayPrice: data["weekday_price"],
      weekendPrice: data["weekend_price"],
      photo: fixMediaUrl(data["photo"]),
    );
  }
}
