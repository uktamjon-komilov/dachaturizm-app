import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/type_model.dart';

class EstateTypesProvider with ChangeNotifier {
  List<TypeModel> _items = [];

  List<TypeModel> get items {
    return [..._items];
  }

  getType(id) {
    var result = null;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].id == id) {
        result = _items[i];
      }
    }
    return result;
  }

  Future<List<TypeModel>> fetchAndSetTypes() async {
    const url = "${baseUrl}api/estate-types/";
    // try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(utf8.decode(response.bodyBytes)) as List;
    final List<TypeModel> types = [];
    for (var i = 0; i < extractedData.length; i++) {
      TypeModel typeObj = await TypeModel.fromJson(extractedData[i]);
      types.add(typeObj);
    }
    _items = types;
    notifyListeners();
    // } catch (error) {
    //   print(error);
    // }
    return [..._items];
  }
}
