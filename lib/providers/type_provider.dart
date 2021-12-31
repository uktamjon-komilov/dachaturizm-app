import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../models/type_model.dart';

class EstateTypesProvider with ChangeNotifier {
  final Dio dio;
  List<TypeModel> _items = [];

  EstateTypesProvider({required this.dio});

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

  Future<List<TypeModel>> getTypes() async {
    const url = "${baseUrl}api/estate-types/";
    // try {
    final response = await dio.get(url);
    final extractedData = response.data;
    final List<TypeModel> types = [];
    for (var i = 0; i < extractedData.length; i++) {
      TypeModel typeObj = await TypeModel.fromJson(extractedData[i]);
      types.add(typeObj);
    }
    _items = types;
    // } catch (error) {
    //   print(error);
    // }
    return [..._items];
  }
}
