import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/models/popular_place_model.dart';
import 'package:dachaturizm/models/region_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FacilityProvider with ChangeNotifier {
  final Dio dio;
  List<FacilityModel> _facilities = [];
  List<RegionModel> _regions = [];
  List<PopularPlaceModel> _places = [];

  FacilityProvider({required this.dio});

  List<FacilityModel> get facilities {
    return [..._facilities];
  }

  List<RegionModel> get regions {
    return [..._regions];
  }

  List<PopularPlaceModel> get places {
    return [..._places];
  }

  Future fetchAll() async {
    Future.wait([
      this.getFacilities(),
      this.getAddresses(),
      this.getPopularPlaces(),
    ]);
  }

  Future getFacilities([String categoryId = ""]) async {
    String url = "${baseUrl}api/facilities/";
    if (categoryId != "") {
      url += "?category=${categoryId}";
    }
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
    _regions = regions;
    notifyListeners();
  }

  Future getPopularPlaces() async {
    const url = "${baseUrl}api/popular-places/";
    final response = await dio.get(url);
    List<PopularPlaceModel> places = [];
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      for (int i = 0; i < response.data.length; i++) {
        PopularPlaceModel place = PopularPlaceModel.fromJson(response.data[i]);
        places.add(place);
      }
    }
    _places = places;
    notifyListeners();
  }
}
