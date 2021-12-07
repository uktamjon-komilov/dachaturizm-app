import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class EstateProvider extends ChangeNotifier {
  Map<int, List<EstateModel>> _estates = {};
  List<EstateModel> _searchedTopEstates = [];
  List<EstateModel> _searchedSimpleEstates = [];

  Map get estates {
    return {..._estates};
  }

  List<EstateModel> get searchedTopEstates {
    return [..._searchedTopEstates];
  }

  List<EstateModel> get searchedSimpleEstates {
    return [..._searchedSimpleEstates];
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

        if (highestRatedEstate == null) {
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
    notifyListeners();
  }

  Future getData(url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body);
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

  Future<List<EstateModel>> search(
    String typeSlug,
    String priority, {
    String term = "",
    String address = "",
    String fromDate = "",
    String toDate = "",
    int people = -1,
    double price = -1.0,
    String facilityIds = "",
  }) async {
    List<EstateModel> searchedEstates = [];
    String url = "${baseUrl}api/estate/${typeSlug}/${priority}/";
    Map<String, dynamic> queryParams = {};
    if (term != "") queryParams["term"] = term;
    if (address != "") queryParams["address"] = address;
    if (fromDate != "") queryParams["fromDate"] = fromDate;
    if (toDate != "") queryParams["toDate"] = toDate;
    if (people != -1) queryParams["people"] = people;
    if (price != -1.0) queryParams["price"] = price;
    if (facilityIds != "") queryParams["facility_ids"] = facilityIds;
    final query = Uri(queryParameters: queryParams).query;
    if (query != "") {
      url = url + "?" + query;
    }
    print(url);
    var response = await http.get(Uri.parse(url));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      var extractedData = json.decode(response.body);
      while (extractedData.containsKey("results") &&
          extractedData.containsKey("links")) {
        print(extractedData);
        List results = extractedData["results"];
        var next = extractedData["links"]["next"];
        for (int i = 0; i < results.length; i++) {
          EstateModel estate = await EstateModel.fromJson(results[i]);
          searchedEstates.add(estate);
        }
        if (next != "" && next != null) {
          response = await http.get(Uri.parse(url));
          if (response.statusCode >= 200 || response.statusCode < 300) {
            extractedData = json.decode(response.body);
          }
        } else
          break;
      }
    }
    return searchedEstates;
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
      typeSlug,
      "top",
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
      typeSlug,
      "simple",
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

  void unsetSearchedResults() {
    _searchedTopEstates = [];
    _searchedSimpleEstates = [];
  }
}