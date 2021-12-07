import "dart:convert";
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:flutter/cupertino.dart';
import "package:http/http.dart" as http;

class BannerProvider extends ChangeNotifier {
  List<EstateModel> _topBanners = [];

  List<EstateModel> get topBanners {
    return [..._topBanners];
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
}
