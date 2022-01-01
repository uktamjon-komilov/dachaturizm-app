import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class EstateProvider with ChangeNotifier {
  // Provider Constructor
  final Dio dio;
  final AuthProvider auth;
  EstateProvider({required this.dio, required this.auth});

  // Headers with auth token if exists
  Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {"Content-type": "application/json"};
    String access = await auth.getAccessToken();
    if (access != "") {
      headers["Authorization"] = "Bearer ${access}";
    }
    return headers;
  }

  // Start
  // Top Estates
  Map<int, List<EstateModel>> _topEstates = {};

  Map get topEstates {
    return {..._topEstates};
  }

  _fetch(String url) async {
    Map<String, dynamic> headers = await getHeaders();
    Response response = await dio.get(
      url,
      options: Options(headers: headers),
    );
    return response;
  }

  Future<Map<int, List<EstateModel>>> _setTopEstates(dynamic data,
      CategoryModel category, Map<int, List<EstateModel>> result) async {
    await data["results"].forEach((item) async {
      EstateModel estate = await EstateModel.fromJson(item);
      result[category.id]!.add(estate);
    });
    return result;
  }

  Future<Map<int, List<EstateModel>>> getTopEstates(
      List<CategoryModel> categories) async {
    Map<int, List<EstateModel>> estates = {};
    dynamic data;
    for (int i = 0; i < categories.length; i++) {
      if (!estates.containsKey(categories[i].slug)) {
        estates[categories[i].id] = [];
      }
      String url = "${baseUrl}api/estate/${categories[i].slug}/top/";
      Response response = await _fetch(url);
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        data = response.data;
        estates = await _setTopEstates(data, categories[i], estates);
        while (data["links"]["next"] != null) {
          data = await _fetch(data["links"]["next"]);
          estates = await _setTopEstates(data, categories[i], estates);
        }
      }
    }
    _topEstates = estates;
    notifyListeners();
    return estates;
  }
  // Top Estates
  // End

  Future<Map<String, dynamic>> getEstatesByType(
    CategoryModel? category,
    String type,
  ) async {
    Map<String, dynamic> data = {};
    final url = "${baseUrl}api/estate/${category!.slug}/${type}/";
    List<EstateModel> estates = [];
    try {
      Response response = await _fetch(url);
      data["next"] = response.data["links"]["next"];
      await response.data["results"].forEach((item) async {
        EstateModel estate = await EstateModel.fromJson(item);
        estates.add(estate);
      });
    } catch (e) {}
    data["estates"] = estates;
    return data;
  }

  Future<Map<String, dynamic>> getNextPage(String url) async {
    print(url);
    Map<String, dynamic> data = {};
    List<EstateModel> estates = [];
    try {
      Response response = await _fetch(url);
      print(response);
      data["next"] = response.data["links"]["next"];
      await response.data["results"].forEach((item) async {
        EstateModel estate = await EstateModel.fromJson(item);
        estates.add(estate);
      });
    } catch (e) {
      print(e);
    }
    data["estates"] = estates;
    print(data);
    return data;
  }

  // Get estate by ID
  Future<EstateModel> fetchEstateById(estateId) async {
    final url = "${baseUrl}api/estate/${estateId}/";
    var extractedData = await _fetch(url);
    var estate = await EstateModel.fromJson(extractedData);
    return estate;
  }

  // Prepare data for creation/updating
  prepareData(data, [estate]) async {
    final locale = await getCurrentLocale();
    Map<String, dynamic> tempData = {};

    if (data.containsKey("photos")) {
      int i = 0;

      while (data["photos"].length > 0) {
        if (data["photos"].length == i) break;
        var photo = await MultipartFile.fromFile(data["photos"][i].path,
            filename: "testimage.png");
        tempData["photo${i + 1}"] = photo;
        i += 1;
      }
    }

    if (data.containsKey("photo")) {
      tempData["photo"] = await MultipartFile.fromFile(data["photo"].path,
          filename: "testimage.png");
    }

    Map<String, dynamic> translations = {
      "en": {
        "title": "",
        "description": "",
        "region": data["region"].translations["en"]["title"],
        "district": data["region"].translations["en"]["title"],
      },
      "uz": {
        "title": "",
        "description": "",
        "region": data["region"].translations["uz"]["title"],
        "district": data["region"].translations["uz"]["title"],
      },
      "ru": {
        "title": "",
        "description": "",
        "region": data["region"].translations["ru"]["title"],
        "district": data["region"].translations["ru"]["title"],
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
    String refresh = await auth.getRefreshToken();
    if (refresh == null || refresh == "") {
      return {"statusCode": 400};
    }
    String access = await auth.getAccessToken();
    Options options = Options(headers: {
      "Content-type": "multipart/form-data",
      "Authorization": "Bearer ${access}",
    });

    Map<String, dynamic> tempData = await prepareData(data);

    try {
      FormData formData = FormData.fromMap(tempData);
      var response = await dio.post(url, data: formData, options: options);
      return {"statusCode": response.statusCode};
    } catch (e) {
      print(e);
    }
    return {"statusCode": 400};
  }

  // Estate updating future
  Future updateEstate(userId, data, estate) async {
    final url = "${baseUrl}api/estate/${userId}/";
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
    } catch (e) {
      print(e);
    }
    return {"statusCode": 400};
  }

  // Getting my estates
  Future getMyEstates() async {
    const url = "${baseUrl}api/estate/myestates/";
    final access = await auth.getAccessToken();
    try {
      final response = await dio.get(
        url,
        options: Options(headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer ${access}",
        }),
      );
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        List<EstateModel> estates = [];
        await response.data.forEach((item) async {
          EstateModel estate = await EstateModel.fromJson(item);
          estates.add(estate);
        });
        return estates;
      }
    } catch (e) {}

    return [];
  }

  // Advertise estate
  Future<bool> advertise(String plan, String id) async {
    final url = "${baseUrl}api/advertise/${plan}/${id}/";
    final access = await auth.getAccessToken();
    try {
      final response = await dio.post(url,
          options: Options(headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer ${access}"
          }));
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        return true;
      }
      return false;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Add/remove estate to/from wishlist
  Future toggleWishlist(int id, bool value) async {
    String url = "";
    if (value)
      url = "${baseUrl}api/wishlist/remove-from-wishlist/";
    else
      url = "${baseUrl}api/wishlist/add-to-wishlist/";
    String access = await auth.getAccessToken();
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer ${access}"
    };
    try {
      final response = await dio.post(url,
          data: {"estate": id}, options: Options(headers: headers));
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        return !value;
      }
    } catch (e) {}
    return null;
  }

  // Getting my wishlist
  Future myWishlist() async {
    const url = "${baseUrl}api/wishlist/mywishlist/";
    String access = await auth.getAccessToken();
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer ${access}"
    };
    List<EstateModel> estates = [];
    try {
      final response = await dio.post(url, options: Options(headers: headers));
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        await response.data.forEach((item) async {
          EstateModel estate = await EstateModel.fromJson(item["estate"]);
          estate.isLiked = true;
          estates.add(estate);
        });
        return estates;
      }
    } catch (e) {}
    return estates;
  }

  // Adding a estate view
  Future addEstateView(String ip, int estateId) async {
    const url = "${baseUrl}api/views/";
    await dio.post(url, data: {"estate": estateId, "ip": ip});
  }
}
