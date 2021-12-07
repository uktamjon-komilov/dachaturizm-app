import "dart:convert";
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:flutter/cupertino.dart';
import "package:http/http.dart" as http;

class BannerProvider extends ChangeNotifier {
  List<EstateModel> _topBanners = [];
  Map<int, List<EstateModel>> _banners = {};

  List<EstateModel> get topBanners {
    return [..._topBanners];
  }

  Map get banners {
    return {..._banners};
  }

  Future<List<EstateModel>> getAndSetTopBanners() async {
    const url = "${baseUrl}api/estate/topbanners/";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      _topBanners = [];
      final extractedData = json.decode(response.body) as List;
      for (var i = 0; i < extractedData.length; i++) {
        final banner = await EstateModel.fromJson(extractedData[i]);
        _topBanners.add(banner);
      }
    } else {
      _topBanners = [];
    }
    notifyListeners();
    return _topBanners;
  }

  Future<Map<int, List<EstateModel>>> getAndSetBanners(
      List<TypeModel> types) async {
    Map<int, List<EstateModel>> banners = {};
    for (var i = 0; i < types.length; i++) {
      final url = "${baseUrl}api/banners/${types[i].slug}/";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode >= 200 || response.statusCode < 300) {
        List extractedData = json.decode(response.body);
        banners[types[i].id] = [];
        for (var j = 0; j < extractedData.length; j++) {
          EstateModel banner =
              await EstateModel.fromJsonAsBanner(extractedData[j]["estate"]);
          banners[types[i].id]!.add(banner);
        }
      }
    }
    _banners = banners;
    return {...banners};
  }
}
