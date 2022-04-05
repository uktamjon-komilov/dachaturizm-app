import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/ads_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HorizontalAdsProvider with ChangeNotifier {
  final Dio dio;
  String? nextLink;

  HorizontalAdsProvider({required this.dio});

  Future<AdsPlusModel?> getAdsPlus({String? url}) async {
    try {
      if (url == null) {
        url = nextLink.toString();
      }
      final response = await dio.get(url);
      if (response.statusCode as int >= 200 &&
          response.statusCode as int < 300) {
        nextLink = response.data["next"];
        return AdsPlusModel.fromJson(response.data["results"][0]);
      }
    } catch (e) {
      return null;
    }
  }
}
