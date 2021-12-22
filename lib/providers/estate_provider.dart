import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/photo_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class EstateProvider with ChangeNotifier {
  final Dio dio;

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

  EstateProvider({required this.dio});

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

  Future fetchEstateById(estateId) async {
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
    try {
      final response = await dio.get(url);
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

  Future<Map<String, dynamic>> createEstate(Map<String, dynamic> data) async {
    const url = "${baseUrl}api/estate/";
    final locale = await getCurrentLocale();

    Map<String, dynamic> tempData = {};

    int i = 0;
    while (data["photos"].length > 0) {
      if (data["photos"].length == i) break;
      var photo = MultipartFile.fromFile(data["photos"][i].path,
          filename: "testimage.png");
      tempData["photo${i + 1}"] = photo;
    }

    Map<String, dynamic> translations = {
      "en": {
        "title": "",
        "description": "",
      },
      "uz": {
        "title": "",
        "description": "",
      },
      "ru": {
        "title": "",
        "description": "",
      }
    };

    translations[locale.toString()] = {
      "title": data["title"],
      "description": data["description"]
    };

    tempData["translations"] = json.encode(translations);
    tempData["estate_type"] = data["estate_type"];
    tempData["price_type"] = data["price_type"];
    tempData["beds"] = data["beds"];
    tempData["pool"] = data["pool"];
    tempData["people"] = data["people"];
    tempData["weekday_price"] = data["weekday_price"];
    tempData["weekend_price"] = data["weekend_price"];
    tempData["address"] = data["address"];
    tempData["longtitute"] = data["longtitute"];
    tempData["latitute"] = data["latitute"];
    tempData["announcer"] = data["announcer"];
    tempData["phone"] = data["phone"];
    tempData["is_published"] = data["is_published"];
    tempData["facilities"] = "[${data['facilities'].join(',')}]";
    tempData["booked_days"] = "[${data['booked_days'].join(',')}]";

    FormData formData = FormData.fromMap(tempData);
    var response = await dio.post(url, data: formData);

    // print(response.data);
    return {"statusCode": response.statusCode};
  }
}
