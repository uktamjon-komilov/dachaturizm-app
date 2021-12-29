import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/photo_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class EstateProvider with ChangeNotifier {
  final Dio dio;
  final AuthProvider auth;

  EstateProvider({required this.dio, required this.auth});

  Map<int, List<EstateModel>> _estates = {};
  List<EstateModel> _searchedTopEstates = [];
  List<EstateModel> _searchedSimpleEstates = [];
  List<EstateModel> _searchedAllEstates = [];
  Map<String, dynamic> _searchFilters = {
    "region": "",
    "priceType": 0,
    "fromPrice": 0.0,
    "toPrice": 0.0,
    "facilities": []
  };

  Map get estates {
    return {..._estates};
  }

  List<EstateModel> get searchedTopEstates {
    return [..._searchedTopEstates];
  }

  List<EstateModel> get searchedSimpleEstates {
    return [..._searchedSimpleEstates];
  }

  List<EstateModel> get searchedAllEstates {
    return [..._searchedAllEstates];
  }

  Map<String, dynamic> get searchFilters {
    return {..._searchFilters};
  }

  bool get hasFilters {
    return !(_searchFilters["region"] == "" &&
        _searchFilters["priceType"] == 0 &&
        _searchFilters["fromPrice"] == 0.0 &&
        _searchFilters["toPrice"] == 0.0 &&
        _searchFilters["facilities"].length == 0);
  }

  List getEstatesByType(typeId, {top = false}) {
    if (_estates.containsKey(typeId)) {
      List<EstateModel> chosenEstates = [];
      _estates[typeId]?.forEach((estate) {
        if (top) {
          if (estate.isTop) {
            chosenEstates.add(estate);
          }
        } else {
          if (!estate.isTop) {
            chosenEstates.add(estate);
          }
        }
      });
      if (chosenEstates.length % 2 == 1) {
        var highestRatedEstate;
        double maxRating = 0.0;

        for (int i = 0; i < _estates[typeId]!.length; i++) {
          if (!_estates[typeId]![i].isTop &&
              _estates[typeId]![i].rating > maxRating) {
            highestRatedEstate = _estates[typeId]![i];
            maxRating = highestRatedEstate.rating;
          }
        }

        if (chosenEstates.length == 1) {
        } else if (highestRatedEstate == null) {
          chosenEstates.removeAt(chosenEstates.length - 1);
        } else {
          chosenEstates.add(highestRatedEstate);
        }
      }
      return chosenEstates;
    }
    return [];
  }

  getEstate(estateId, typeId) {
    for (var i = 0; i < _estates[typeId]!.length; i++) {
      if (_estates[typeId]![i].id == estateId) {
        return _estates[typeId]![i];
      }
    }

    return null;
  }

  Future<EstateModel> fetchEstateById(estateId) async {
    final url = "${baseUrl}api/estate/${estateId}/";
    var extractedData = await getData(url);
    var estate = await EstateModel.fromJson(extractedData);
    return estate;
  }

  Future<void> fetchAllAndSetEstates() async {
    const url = "${baseUrl}api/estate/";
    Map<int, List<EstateModel>> estates = {};
    // try {
    var extractedData = await getData(url);
    estates = await setData(extractedData, estates);
    estates = await checkNextPage(extractedData, estates);
    _estates = estates;
    // } catch (error) {
    //   print(error);
    // }
    // print(_estates);
  }

  Future getData(url) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    String access = await auth.getAccessToken();
    String refresh = await auth.getRefreshToken();
    if (access != "" && refresh != "")
      headers["Authorization"] = "Bearer ${access}";

    try {
      final response = await dio.get(url, options: Options(headers: headers));
      final extractedData = response.data;
      return extractedData;
    } catch (error) {
      throw error;
    }
  }

  Future<Map<int, List<EstateModel>>> setData(data, estates) async {
    await data["results"].forEach((estate) async {
      int estate_type = estate["estate_type"];
      if (!estates.containsKey(estate_type)) {
        List<EstateModel> _list = [];
        estates[estate_type] = _list;
      }
      List<EstatePhotos> photos = [];
      for (var i = 0; i < estate["photos"].length; i++) {
        photos.add(EstatePhotos(
            id: estate["photos"][i]["id"],
            photo: estate["photos"][i]["photo"]));
      }
      EstateModel object = await EstateModel.fromJson(estate);
      estates[estate_type]?.add(object);
    });

    return {...estates};
  }

  Future<Map<int, List<EstateModel>>> checkNextPage(data, Map estates) async {
    var nextPageLink = data["links"]["next"];
    if (nextPageLink.toString().contains("page")) {
      var extractedData = await getData(nextPageLink);
      estates = await setData(extractedData, estates);
      return checkNextPage(extractedData, estates);
    } else {
      return {...estates};
    }
  }

  Future<List<EstateModel>> _search(
    url,
    query,
  ) async {
    if (query != "") {
      url = url + "?" + query;
    }
    List<EstateModel> searchedEstates = [];
    var response = await dio.get(url);
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      var extractedData = response.data;
      while (extractedData.containsKey("results")) {
        List results = extractedData["results"];
        for (int i = 0; i < results.length; i++) {
          EstateModel estate = await EstateModel.fromJson(results[i]);
          searchedEstates.add(estate);
        }
        var next = extractedData["links"]["next"];
        if (next == "" || next == null) {
          break;
        } else {
          response = await dio.get(next);
          if (response.statusCode as int >= 200 ||
              response.statusCode as int < 300) {
            extractedData = response.data;
          }
        }
      }
    }
    return searchedEstates;
  }

  Future<List<EstateModel>> search({
    String typeSlug = "",
    String priority = "",
    String term = "",
    String address = "",
    String fromDate = "",
    String toDate = "",
    int people = -1,
    double price = -1.0,
    String facilityIds = "",
    bool all = false,
  }) async {
    String url = "";
    if (all) {
      url = "${baseUrl}api/estate/";
    } else {
      url = "${baseUrl}api/estate/${typeSlug}/${priority}/";
    }
    Map<String, dynamic> queryParams = {};
    if (term != "") queryParams["term"] = term;
    if (address != "") queryParams["address"] = address;
    if (fromDate != "") queryParams["fromDate"] = fromDate;
    if (toDate != "") queryParams["toDate"] = toDate;
    if (people != -1) queryParams["people"] = people;
    if (price != -1.0) queryParams["price"] = price;
    if (facilityIds != "") queryParams["facility_ids"] = facilityIds;
    final query = Uri(queryParameters: queryParams).query;
    return _search(url, query);
  }

  Future<void> searchTop(
    String typeSlug, {
    String term = "",
    String address = "",
    String fromDate = "",
    String toDate = "",
    int people = -1,
    double price = -1.0,
    String facilityIds = "",
  }) async {
    List<EstateModel> searchedTopEstates = await search(
      typeSlug: typeSlug,
      priority: "top",
      term: term,
      address: address,
      fromDate: fromDate,
      toDate: toDate,
      people: people,
      price: price,
      facilityIds: facilityIds,
    );
    _searchedTopEstates = searchedTopEstates;
  }

  Future<void> searchSimple(
    String typeSlug, {
    String term = "",
    String address = "",
    String fromDate = "",
    String toDate = "",
    int people = -1,
    double price = -1.0,
    String facilityIds = "",
  }) async {
    List<EstateModel> searchedSimpleEstates = await search(
      typeSlug: typeSlug,
      priority: "simple",
      term: term,
      address: address,
      fromDate: fromDate,
      toDate: toDate,
      people: people,
      price: price,
      facilityIds: facilityIds,
    );
    _searchedSimpleEstates = searchedSimpleEstates;
  }

  Future<void> searchAll({
    String term = "",
    String address = "",
    String fromDate = "",
    String toDate = "",
    int people = -1,
    double price = -1.0,
    String facilityIds = "",
  }) async {
    List<EstateModel> searchedAllEstates = await search(
      term: term,
      address: address,
      fromDate: fromDate,
      toDate: toDate,
      people: people,
      price: price,
      facilityIds: facilityIds,
      all: true,
    );
    _searchedAllEstates = searchedAllEstates;
  }

  void unsetSearchedResults() {
    _searchedTopEstates = [];
    _searchedSimpleEstates = [];
    _searchedAllEstates = [];
  }

  void setRegionFilter(String region) {
    _searchFilters["region"] = region;
    notifyListeners();
  }

  void setPriceType(int id) {
    _searchFilters["priceType"] = id;
    notifyListeners();
  }

  void setFromPriceFilter(String price) {
    _searchFilters["fromPrice"] = double.parse(price);
    notifyListeners();
  }

  void setToPriceFilter(String price) {
    _searchFilters["toPrice"] = double.parse(price);
    notifyListeners();
  }

  void addFacilityFilter(int id) {
    if (_searchFilters["facilities"].indexOf(id) == -1)
      _searchFilters["facilities"].add(id);
    notifyListeners();
  }

  void removeFacilityFilter(int id) {
    if (_searchFilters["facilities"].indexOf(id) == -1)
      _searchFilters["facilities"].remove(id);
    notifyListeners();
  }

  void clearSearchFilters() {
    _searchFilters["region"] = "";
    _searchFilters["priceType"] = 0;
    _searchFilters["fromPrice"] = 0.0;
    _searchFilters["toPrice"] = 0.0;
    _searchFilters["facilities"] = [];
    notifyListeners();
  }

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

  Future addEstateView(String ip, int estateId) async {
    const url = "${baseUrl}api/views/";
    await dio.post(url, data: {"estate": estateId, "ip": ip});
  }
}
