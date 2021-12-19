import "dart:convert";
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class BannerProvider extends ChangeNotifier {
  final Dio dio;

  List<EstateModel> _topBanners = [];
  Map<int, List<EstateModel>> _banners = {};

  BannerProvider({required this.dio});

  List<EstateModel> get topBanners {
    return [..._topBanners];
  }

  Map get banners {
    return {..._banners};
  }

  Future<List<EstateModel>> getAndSetTopBanners() async {
    const url = "${baseUrl}api/estate/topbanners/";
    final response = await dio.get(url);
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      _topBanners = [];
      final extractedData = response.data;
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
      final response = await dio.get(url);
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        List extractedData = response.data;
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
