import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/currency_model.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class CurrencyProvider extends ChangeNotifier {
  List<CurrencyModel> _currencies = [];

  List<CurrencyModel> get currencies {
    return [..._currencies];
  }

  Future<List<CurrencyModel>> fetchAndSetCurrencies() async {
    const url = "${baseUrl}api/currencies/";
    List<CurrencyModel> currencies = [];
    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      var extractedData = json.decode(utf8.decode(response.bodyBytes));
      for (int i = 0; i < extractedData.length; i++) {
        CurrencyModel currency = await CurrencyModel.fromJson(extractedData[i]);
        currencies.add(currency);
        print(extractedData[i]);
      }
    }
    _currencies = currencies;
    notifyListeners();
    return [..._currencies];
  }
}
