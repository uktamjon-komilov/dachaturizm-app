import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class FacilityProvider extends ChangeNotifier {
  List<FacilityModel> _facilities = [];

  List<FacilityModel> get facilities {
    return [..._facilities];
  }

  Future<List<FacilityModel>> fetchAndSetFacilities() async {
    const url = "${baseUrl}api/facilities/";
    final response = await http.get(Uri.parse(url));
    List<FacilityModel> facilities = [];
    if (response.statusCode >= 200 || response.statusCode < 300) {
      final extractedData = json.decode(utf8.decode(response.bodyBytes));
      for (int i = 0; i < extractedData.length; i++) {
        FacilityModel facility = await FacilityModel.fromJson(extractedData[i]);
        facilities.add(facility);
      }
      _facilities = facilities;
      notifyListeners();
    }

    return [...facilities];
  }
}
