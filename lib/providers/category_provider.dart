import 'package:dachaturizm/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../models/category_model.dart';

class EstateTypesProvider with ChangeNotifier {
  final Dio dio;
  List<CategoryModel> _categories = [];

  EstateTypesProvider({required this.dio});

  List<CategoryModel> get categories {
    return [..._categories];
  }

  getType(id) {
    var result = null;
    for (var i = 0; i < _categories.length; i++) {
      if (_categories[i].id == id) {
        result = _categories[i];
      }
    }
    return result;
  }

  Future<List<CategoryModel>> getCategories() async {
    const url = "${baseUrl}api/estate-types/";
    final response = await dio.get(url);
    final extractedData = response.data;
    final List<CategoryModel> categories = [];
    for (var i = 0; i < extractedData.length; i++) {
      CategoryModel typeObj = await CategoryModel.fromJson(extractedData[i]);
      categories.add(typeObj);
    }
    _categories = categories;
    return [...categories];
  }
}
