import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/ads_plan.dart';
import 'package:dachaturizm/models/currency_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  final Dio dio;
  List<CurrencyModel> _currencies = [];

  CurrencyProvider({required this.dio});

  List<CurrencyModel> get currencies {
    return [..._currencies];
  }

  Future getCurrencies() async {
    const url = "${baseUrl}api/currencies/";
    List<CurrencyModel> currencies = [];
    final response = await dio.get(url);
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      var extractedData = response.data;
      for (int i = 0; i < extractedData.length; i++) {
        CurrencyModel currency = await CurrencyModel.fromJson(extractedData[i]);
        currencies.add(currency);
      }
    }
    _currencies = currencies;
    notifyListeners();
  }

  Future<List<AdPlan>> fetchAdPlans() async {
    const url = "${baseUrl}api/advertising-plans/";
    List<AdPlan> plans = [];
    final response = await dio.get(url);
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      await response.data.forEach((item) async {
        AdPlan plan = await AdPlan.fromJson(item);
        plans.add(plan);
      });
    }
    return plans;
  }

  Future getPaymentLinks(String type, int userId, double amount,
      {String? returnUrl}) async {
    final url = "${baseUrl}api/payment-links/${type}/";
    try {
      final response = await dio.post(url, data: {
        "user": userId,
        "amount": amount,
        "return_url": "https://dachaturizm.uz/"
      });

      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        return response.data["link"];
      }
    } catch (e) {}

    return "";
  }
}
