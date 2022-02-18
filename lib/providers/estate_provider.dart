import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/models/estate_rating_model.dart';
import 'package:dachaturizm/models/static_page_model.dart';
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

  Future<Response> _fetch(String url) async {
    Map<String, dynamic> headers = await getHeaders();
    Response response = await dio.get(
      url,
      options: Options(headers: headers),
    );
    return response;
  }

  Future<Map<int, List<EstateModel>>> _setTopEstates(
      data, CategoryModel category, Map<int, List<EstateModel>> result) async {
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
          response = await _fetch(data["links"]["next"]);
          estates = await _setTopEstates(response.data, categories[i], estates);
          data = response.data;
        }
      }
    }
    _topEstates = estates;
    notifyListeners();
    return estates;
  }
  // Top Estates
  // End

  // Get estates by category and type
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

  // Get any data from the next page
  Future<Map<String, dynamic>> getNextPage(String url) async {
    Map<String, dynamic> data = {};
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

  // Get static pages
  Future<List<StaticPageModel>> getStaticPages() async {
    List<StaticPageModel> pages = [];
    const url = "${baseUrl}api/staticpages/";
    final response = await dio.get(url);
    await response.data.forEach((item) async {
      StaticPageModel page = await StaticPageModel.fromJson(item);
      pages.add(page);
    });
    return pages;
  }

  // Begin
  // Search
  List _sorting = ["latest", "cheapest", "expensive"];
  Map<String, dynamic> _filters = {
    "sorting": "latest",
    "address": "",
    "region": 0,
    "district": 0,
    "place": 0,
    "minPrice": 0.0,
    "maxPrice": 0.0,
    "priceType": null,
    "facilities": []
  };

  Map<String, dynamic> get filters {
    return {..._filters};
  }

  String getQueryStringFromFilters(
      {String? term,
      CategoryModel? category,
      Map<String, dynamic>? extraArgs = const {}}) {
    String queryString = Uri(
      host: "",
      scheme: "",
      path: "",
      queryParameters: {
        "estate_type":
            category == null ? null.toString() : category.id.toString(),
        "sorting": _filters["sorting"],
        "address": _filters["address"],
        "region": _filters["region"].toString(),
        "district": _filters["district"].toString(),
        "place": _filters["place"].toString(),
        "term": term ?? "",
        "min_price": _filters["minPrice"].toString(),
        "max_price": _filters["maxPrice"].toString(),
        "price_type": _filters["priceType"].toString(),
        "facility_ids": _filters["facilities"].join(","),
        "is_top": extraArgs!.containsKey("top")
            ? extraArgs["top"].toString()
            : "false",
        "is_simple": extraArgs.containsKey("simple")
            ? extraArgs["simple"].toString()
            : "false",
      },
    ).query;
    return queryString;
  }

  List<String> get sorting {
    return [..._sorting];
  }

  filtersSorting(String sort) {
    _filters["sorting"] = sort;
    notifyListeners();
  }

  filtersAddress(String address) {
    _filters["address"] = address;
  }

  filtersRegion(int regionId) {
    _filters["region"] = regionId;
  }

  filtersDistrict(int districtId) {
    _filters["district"] = districtId;
  }

  filtersPlace(int id) {
    _filters["place"] = id;
  }

  filtersMinPrice(double price) {
    _filters["minPrice"] = price;
  }

  filtersMaxPrice(double price) {
    _filters["maxPrice"] = price;
  }

  filtersPriceType(int priceType) {
    _filters["priceType"] = priceType;
  }

  filtersToggleFacility(int id) {
    if (_filters["facilities"].contains(id))
      _filters["facilities"].remove(id);
    else
      _filters["facilities"].add(id);
  }

  filtersClear() {
    _filters = {
      "sorting": "latest",
      "address": "",
      "place": 0,
      "region": 0,
      "district": 0,
      "minPrice": 0.0,
      "maxPrice": 0.0,
      "priceType": null,
      "facilities": []
    };
    notifyListeners();
  }
  // Search
  // End

  // Search and return results
  Future<Map<String, dynamic>> getSearchedResults({
    String? term,
    CategoryModel? category,
    Map<String, dynamic>? extraArgs = const {},
  }) async {
    Map<String, dynamic> data = {};
    List<EstateModel> estates = [];
    String queryString = getQueryStringFromFilters(
      term: term,
      category: category,
      extraArgs: extraArgs,
    );
    final url = "${baseUrl}api/estate/?${queryString}";
    final response = await _fetch(url);
    await response.data["results"].forEach((item) async {
      EstateModel estate = await EstateModel.fromJson(item);
      estates.add(estate);
    });
    data["estates"] = estates;
    data["next"] = response.data["links"]["next"];
    return data;
  }

  // Get estate by ID
  Future<EstateModel> getEstateById(int estateId) async {
    final url = "${baseUrl}api/estate/${estateId}/";
    Response response = await _fetch(url);
    var estate = await EstateModel.fromJson(response.data);
    return estate;
  }

  // Get detail page ad
  Future<EstateModel?> getAd() async {
    const url = "${baseUrl}api/estate/ads/";
    Response response = await _fetch(url);
    if (response.data.length == 0) return null;
    EstateModel estate = await EstateModel.fromJson(response.data);
    return estate;
  }

  // Get estate ratings
  Future<EstateRatingModel> getEstateRatings(int estateId) async {
    final url = "${baseUrl}api/ratings/${estateId}/related/";
    Response response = await dio.get(url);
    return EstateRatingModel.fromJson(response.data);
  }

  // Save estate rating
  Future saveRating(int estateId, double rating) async {
    const url = "${baseUrl}api/ratings/";
    final userId = await auth.getUserId();
    final access = await auth.getAccessToken();
    Map<String, dynamic> data = {
      "estate": estateId,
      "user": userId,
      "rating": rating,
    };
    final response = await dio.post(
      url,
      data: data,
      options: Options(headers: {"Authorization": "Bearer ${access}"}),
    );
  }

  // Get similar estates
  Future<List<EstateModel>> getSimilarEstates(int estateId) async {
    List<EstateModel> estates = [];
    final url = "${baseUrl}api/estate/${estateId}/similar/";
    try {
      final response = await dio.get(url);
      await response.data.forEach((item) async {
        EstateModel estate = await EstateModel.fromJson(item);
        estates.add(estate);
      });
    } catch (e) {}
    return estates.sublist(0, 2);
  }

  // Get user's estates
  Future<List<EstateModel>> getUserEstates(int userId) async {
    List<EstateModel> estates = [];
    const url = "${baseUrl}api/users/estates/";
    Map<String, dynamic> data = {"user": userId};
    final response = await dio.post(url, data: data);
    await response.data.forEach((item) async {
      EstateModel estate = await EstateModel.fromJson(item);
      estates.add(estate);
    });
    return estates;
  }

  // Get extrimal prices
  Future<Map<String, dynamic>> getExtrimalPrices(int priceTypeId,
      {int? categoryId}) async {
    const url = "${baseUrl}api/extrimal-prices/";
    Map<String, int> data = {"price_type": priceTypeId};
    if (categoryId != null) {
      data["category"] = categoryId;
    }
    final response = await dio.post(url, data: data);
    return response.data;
  }

  // Prepare data for creation/updating
  prepareData(data, [estate]) async {
    final locale = await getCurrentLocale();
    Map<String, dynamic> tempData = {};

    // if (data.containsKey("photos")) {
    //   int i = 0;

    //   while (data["photos"].length > 0) {
    //     if (data["photos"].length == i) break;
    //     var photo;
    //     if (data["photos"][i].runtimeType.toString() == "String") {
    //       photo = data["photos"][i];
    //     } else {
    //       photo = await MultipartFile.fromFile(data["photos"][i].path,
    //           filename: "testimage.png");
    //     }
    //     tempData["photo${i + 1}"] = photo;
    //     i += 1;
    //   }
    // }
    tempData["photos"] = "[${data['photos'].join(',')}]";

    // if (data.containsKey("photo")) {
    //   if (data["photo"].runtimeType.toString() == "String") {
    //     tempData["photo"] = data["photo"];
    //   } else {
    //     tempData["photo"] = await MultipartFile.fromFile(data["photo"].path,
    //         filename: "testimage.png");
    //   }
    // }
    tempData["photo"] = data["photo"];

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

    if (data.containsKey("popular_place_id")) {
      tempData["popular_place_id"] = data["popular_place_id"];
    }

    if (data.containsKey("beds")) {
      tempData["beds"] = 5;
    }

    if (data.containsKey("pool")) {
      tempData["pool"] = 1;
    }

    if (data.containsKey("people")) {
      tempData["people"] = 5;
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
    } catch (e) {
      print(e);
    }
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
    } catch (e) {
      print(e);
    }
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
    } catch (e) {
      print(e);
    }
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
    } catch (e) {
      print(e);
    }
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
    } catch (e) {
      print(e);
    }
    return 0;
  }

  // Getting my estates
  Future<List<EstateModel>> getMyEstates([String? term]) async {
    String url = "";
    if (term == null) {
      url = "${baseUrl}api/estate/myestates/";
    } else {
      url = "${baseUrl}api/estate/myestates/?term=${term}";
    }
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
    } catch (e) {
      print(e);
    }

    return [];
  }

  // Getting my last estate
  Future<EstateModel?> getMyLastEstate() async {
    const url = "${baseUrl}api/estate/last/";
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
        EstateModel estate = await EstateModel.fromJson(response.data);
        return estate;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Advertise estate
  Future<bool> advertise(String slug, int estateId) async {
    final url = "${baseUrl}api/advertise/${slug}/${estateId}/";
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
    } catch (e) {
      print(e);
    }
    return estates;
  }

  // Adding a estate view
  Future addEstateView(String ip, int estateId) async {
    const url = "${baseUrl}api/views/";
    await dio.post(url, data: {"estate": estateId, "ip": ip});
  }
}
