import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/booking_day.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/models/photo_model.dart';

class EstateModel {
  final int id;
  final String title;
  final String description;
  final String priceType;
  final List<BookingDay> bookedDays;
  final List<FacilityModel> facilities;
  final double rating;
  final int views;
  final int userAdsCount;
  final String userPhoto;
  final String photo;
  final String thumbnail;
  final List<EstatePhotos> photos;
  final int beds;
  final int pool;
  final int people;
  final double weekdayPrice;
  final double weekendPrice;
  final String address;
  final String? popularPlaceTitle;
  final String region;
  final String district;
  final double longtitute;
  final double latitute;
  final String announcer;
  final String phone;
  final int userId;
  final int typeId;
  final bool isSimple;
  final bool isTop;
  final bool isBanner;
  final bool isTopBanner;
  final bool isAd;
  final DateTime? created;
  final DateTime? updated;
  final DateTime expiryDate;
  bool isLiked;

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
    this.popularPlaceTitle,
    this.region = "",
    this.district = "",
    this.announcer = "",
    this.phone = "",
    this.userAdsCount = 0,
    this.userPhoto = "",
    this.photo = "",
    this.thumbnail = "",
    this.userId = 0,
    this.typeId = 0,
    this.longtitute = 0.0,
    this.latitute = 0.0,
    this.photos = const [],
    this.bookedDays = const [],
    this.facilities = const [],
    this.isSimple = false,
    this.isTop = false,
    this.isBanner = false,
    this.isTopBanner = false,
    this.isAd = false,
    this.created,
    this.updated,
    required this.expiryDate,
    this.isLiked = false,
  });

  dynamic getAttr(String key) => <String, dynamic>{
        "isTop": this.isTop,
      }[key];

  static String getFromOtherLang(Map<String, dynamic> data, key, currLang) {
    List<String> langs = ["uz", "ru", "en"];
    langs.remove(currLang);
    String value = "";
    langs.forEach((lang) {
      if (value != "" && data.containsKey(lang)) {
        if (data[lang].containsKey(key)) {
          value = data[lang][key];
        }
      }
    });
    return value;
  }

  static Future<EstateModel> fromJson(Map<String, dynamic> data) async {
    List<String> langs = ["uz", "en", "ru"];
    String? locale = await getCurrentLocale();

  Map<String, dynamic> localData = {};

  int counter = 0;

  while(counter < langs.length && !data["translations"].containsKey(locale)){
    locale = langs[counter];
    counter += 1;
  }

    try{
    localData = data["translations"][locale];
    }catch(e){
      locale = null;
    }

    return EstateModel(
      id: data.containsKey("id") ? data["id"] : 0,
      title: locale == null ? "-" : (localData.containsKey("title")
          ? localData["title"]
          : getFromOtherLang(data["translations"], "title", "uz")),
      description: locale == null ? "-" : (localData["description"]),
      region: locale == null ? "-" :(localData.containsKey("region") ? localData["region"] : ""),
      district: locale == null ? "-" : (localData.containsKey("district") ? localData["district"] : ""),
      priceType: data["price_type"]["translations"][locale]["title"],
      rating: data["rating"],
      views: data["views"],
      beds: data["beds"].runtimeType.toString() == "String"
          ? int.parse(data["beds"])
          : data["beds"],
      pool: data["pool"].runtimeType.toString() == "String"
          ? int.parse(data["pool"])
          : data["pool"],
      people: data["people"].runtimeType.toString() == "String"
          ? int.parse(data["people"])
          : data["people"],
      weekdayPrice: data["weekday_price"],
      weekendPrice: data["weekend_price"],
      longtitute: data["longtitute"],
      latitute: data["latitute"],
      address: data["address"],
      popularPlaceTitle: data.containsKey("popular_place_title")
          ? data["popular_place_title"]
          : null,
      announcer: data["announcer"],
      phone: data["phone"],
      userAdsCount: data["user_ads_count"],
      userPhoto: data["user_photo"] ?? "",
      photo: fixMediaUrl(data["photo"]),
      thumbnail: data["thumbnail"] == null
          ? fixMediaUrl(data["photo"])
          : fixMediaUrl(data["thumbnail"]),
      photos: data.keys.contains("photos")
          ? data["photos"]
              .map<EstatePhotos>((item) => EstatePhotos(
                  id: item["id"], photo: fixMediaUrl(item["photo"])))
              .toList()
          : [],
      facilities: data.keys.contains("facilities")
          ? data["facilities"]
              .map<FacilityModel>((item) => FacilityModel(
                  id: item["id"], title: item["translations"][locale]["title"]))
              .toList()
          : [],
      bookedDays: data.keys.contains("booked_days")
          ? data["booked_days"]
              .map<BookingDay>((date) => BookingDay.fromJson(date))
              .toList()
          : [],
      userId: data["user"],
      typeId: data["estate_type"],
      isSimple: data["is_simple"],
      isTop: data["is_top"],
      isBanner: data["is_banner"],
      isTopBanner: data["is_topbanner"],
      isAd: data["is_ads"],
      created: DateTime.parse(data["created_at"].toString().substring(0, 10)),
      updated: DateTime.parse(data["updated_at"].toString().substring(0, 10)),
      expiryDate: DateTime.parse(data["expires_in"]),
      isLiked: data["is_liked"],
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
        expiryDate: DateTime.now());
  }
}
