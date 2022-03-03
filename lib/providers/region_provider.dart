import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/region_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RegionProvider with ChangeNotifier {
  final Dio dio;

  RegionProvider({required this.dio});

  List<RegionModel> _regions = [];

  List<RegionModel> get regions {
    return [..._regions];
  }

  Future getAndSetRegions() async {
    const url = "${baseUrl}api/address/";
    List<RegionModel> regions = [];
    final response = await dio.get(url);
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      final extractedData = response.data;
      for (int i = 0; i < extractedData.length; i++) {
        RegionModel region = await RegionModel.fromJson(extractedData[i]);
        regions.add(region);
      }
    }
    _regions = regions;
    notifyListeners();
  }
}
