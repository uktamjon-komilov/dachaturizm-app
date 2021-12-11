import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/region_model.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class RegionProvider extends ChangeNotifier {
  List<RegionModel> _regions = [];

  List<RegionModel> get regions {
    return [..._regions];
  }

  Future<List<RegionModel>> getAndSetRegions() async {
    const url = "${baseUrl}api/address/";
    List<RegionModel> regions = [];
    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      final extractedData = json.decode(response.body);
      for (int i = 0; i < extractedData.length; i++) {
        RegionModel region = await RegionModel.fromJson(extractedData[i]);
        regions.add(region);
      }
    }
    _regions = regions;
    notifyListeners();
    return [..._regions];
  }
}
