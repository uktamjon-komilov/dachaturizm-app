import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class CreateEstateProvider extends ChangeNotifier {
  final AuthProvider auth;
  final Dio dio;

  CreateEstateProvider({required this.dio, required this.auth});

  // Prepare data for creation/updating
  prepareData(data, [estate]) async {
    final locale = await getCurrentLocale();
    Map<String, dynamic> tempData = {};

    print(data["photos"]);

    tempData["photos"] = "[${data['photos'].join(',')}]";
    print(tempData["photos"]);

    tempData["photo"] = data["photo"];

    Map<String, dynamic> translations = {
      "en": {
        "title": "",
        "description": "",
        "region": data["region"].translations["en"]["title"],
        "district": data["district"].translations["en"]["title"],
      },
      "uz": {
        "title": "",
        "description": "",
        "region": data["region"].translations["uz"]["title"],
        "district": data["district"].translations["uz"]["title"],
      },
      "ru": {
        "title": "",
        "description": "",
        "region": data["region"].translations["ru"]["title"],
        "district": data["district"].translations["ru"]["title"],
      }
    };

    if (data.containsKey("title")) {
      translations[locale.toString()]["title"] = data["title"];
    } else {
      translations[locale.toString()]["title"] = estate.title;
    }

    if (data.containsKey("description")) {
      translations[locale.toString()]["description"] = data["description"];
    } else {
      translations[locale.toString()]["description"] = estate.description;
    }

    tempData["translations"] = json.encode(translations);

    if (data.containsKey("estate_type")) {
      tempData["estate_type"] = data["estate_type"];
    }

    if (data.containsKey("price_type")) {
      tempData["price_type"] = data["price_type"];
    }

    if (data.containsKey("popular_place_id")) {
      tempData["popular_place_id"] = data["popular_place_id"];
    }

    if (data.containsKey("beds")) {
      tempData["beds"] = data["beds"];
    }

    if (data.containsKey("pool")) {
      tempData["pool"] = data["pool"];
    }

    if (data.containsKey("people")) {
      tempData["people"] = data["people"];
    }

    if (data.containsKey("weekday_price")) {
      tempData["weekday_price"] = data["weekday_price"];
    }

    if (data.containsKey("weekend_price")) {
      tempData["weekend_price"] = data["weekend_price"];
    }

    if (data.containsKey("address")) {
      tempData["address"] = data["address"];
    }

    if (data.containsKey("longtitute")) {
      tempData["longtitute"] = data["longtitute"];
    }

    if (data.containsKey("latitute")) {
      tempData["latitute"] = data["latitute"];
    }

    if (data.containsKey("announcer")) {
      tempData["announcer"] = data["announcer"];
    }

    if (data.containsKey("phone")) {
      tempData["phone"] = data["phone"].toString().replaceAll("+", "");
    }

    if (data.containsKey("is_published")) {
      tempData["is_published"] = data["is_published"];
    }

    if (data.containsKey("facilities")) {
      tempData["facilities"] = "[${data['facilities'].join(',')}]";
    }

    if (data.containsKey("booked_days")) {
      tempData["booked_days"] = "[${data['booked_days'].join(',')}]";
    }

    return tempData;
  }

  // Estate creation future
  Future<Map<String, dynamic>> createEstate(Map<String, dynamic> data) async {
    const url = "${baseUrl}api/estate/";
    String? refresh = await auth.getRefreshToken();
    if (refresh == null || refresh == "") {
      return {"statusCode": 400};
    }
    String access = await auth.getAccessToken();
    Options options = Options(
      headers: {
        "Content-type": "multipart/form-data",
        "Authorization": "Bearer ${access}",
      },
    );

    Map<String, dynamic> tempData = await prepareData(data);

    try {
      FormData formData = FormData.fromMap(tempData);
      final response = await dio.post(url, data: formData, options: options);
      return {"statusCode": response.statusCode};
    } catch (e) {}
    return {"statusCode": 400};
  }

  // Estate updating future
  Future updateEstate(estateId, data, estate) async {
    final url = "${baseUrl}api/estate/${estateId}/";
    String refresh = await auth.getRefreshToken();
    if (refresh == null || refresh == "") {
      return {"statusCode": 400};
    }
    String access = await auth.getAccessToken();
    Options options = Options(headers: {
      "Content-type": "multipart/form-data",
      "Authorization": "Bearer ${access}",
    });

    Map<String, dynamic> tempData = await prepareData(data, estate);

    try {
      FormData formData = FormData.fromMap(tempData);
      var response = await dio.patch(url, data: formData, options: options);
      return {"statusCode": response.statusCode};
    } catch (e) {}
    return {"statusCode": 400};
  }

  Future<int> uploadTempPhoto(photo) async {
    try {
      const url = "${baseUrl}api/tempphoto/";
      String access = await auth.getAccessToken();
      Options options = Options(headers: {
        "Content-type": "multipart/form-data",
        "Authorization": "Bearer ${access}",
      });
      FormData formData = FormData.fromMap({"photo": photo});
      final response = await dio.post(url, options: options, data: formData);
      if (response.statusCode as int >= 200 &&
          response.statusCode as int < 300) {
        return response.data["id"];
      }
    } catch (e) {}
    return 0;
  }

  Future<int> uploadExtraPhoto(photo) async {
    try {
      const url = "${baseUrl}api/estatephotos/";
      String access = await auth.getAccessToken();
      Options options = Options(headers: {
        "Content-type": "multipart/form-data",
        "Authorization": "Bearer ${access}",
      });
      FormData formData = FormData.fromMap({"photo": photo});
      final response = await dio.post(url, options: options, data: formData);
      if (response.statusCode as int >= 200 &&
          response.statusCode as int < 300) {
        return response.data["id"];
      }
    } catch (e) {}
    return 0;
  }

  Future<int> updateExtraPhoto(id, photo) async {
    try {
      final url = "${baseUrl}api/estatephotos/${id}/";
      String access = await auth.getAccessToken();
      Options options = Options(headers: {
        "Content-type": "multipart/form-data",
        "Authorization": "Bearer ${access}",
      });
      FormData formData = FormData.fromMap({"photo": photo});
      final response = await dio.patch(url, options: options, data: formData);
      if (response.statusCode as int >= 200 &&
          response.statusCode as int < 300) {
        return response.data["id"];
      }
    } catch (e) {}
    return 0;
  }

  Future<Map<String, bool>> removePhoto(int _id) async {
    try {
      final url = "${baseUrl}api/estatephotos/${_id}/";
      String access = await auth.getAccessToken();
      Options options = Options(headers: {
        "Content-type": "multipart/form-data",
        "Authorization": "Bearer ${access}",
      });
      print(url);
      final response = await dio.delete(url, options: options);
      if (response.statusCode as int >= 200 &&
          response.statusCode as int < 300) {
        return {"status": true};
      }
    } catch (e) {
      print(e);
    }
    return {"status": false};
  }

  // Estate creation future
  Future<Map<String, dynamic>> deleteEstate(String? id) async {
    final url = "${baseUrl}api/estater/${id}/";
    print(url);
    String? refresh = await auth.getRefreshToken();
    if (refresh == null || refresh == "") {
      return {"statusCode": 400};
    }
    String access = await auth.getAccessToken();
    Options options = Options(
      headers: {
        "Content-type": "multipart/form-data",
        "Authorization": "Bearer ${access}",
      },
    );

    try {
      final response = await dio.delete(url, options: options);
      print(response.data);
      return {"statusCode": response.statusCode};
    } catch (e) {
      print(e);
    }
    return {"statusCode": 400};
  }
}
