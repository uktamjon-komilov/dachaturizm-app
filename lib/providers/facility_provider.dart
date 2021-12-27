import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/models/region_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class FacilityProvider with ChangeNotifier {
  final Dio dio;
  List<FacilityModel> _facilities = [];

  FacilityProvider({required this.dio});

  List<FacilityModel> get facilities {
    return [..._facilities];
  }

  Future<List<FacilityModel>> fetchAndSetFacilities() async {
    const url = "${baseUrl}api/facilities/";
    final response = await dio.get(url);
    List<FacilityModel> facilities = [];
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      final extractedData = response.data;
      for (int i = 0; i < extractedData.length; i++) {
        FacilityModel facility = await FacilityModel.fromJson(extractedData[i]);
        facilities.add(facility);
      }
      _facilities = facilities;
      notifyListeners();
    }

    return [...facilities];
  }

  Future getAddresses() async {
    const url = "${baseUrl}api/address/";
    final response = await dio.get(url);
    List<RegionModel> regions = [];
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      for (int i = 0; i < response.data.length; i++) {
        RegionModel region = await RegionModel.fromJson(response.data[i]);
        regions.add(region);
      }
    }
    return regions;
  }
}
