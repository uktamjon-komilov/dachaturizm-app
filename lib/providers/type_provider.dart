import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/type_model.dart';

class EstateTypes with ChangeNotifier {
  List<TypeModel> _items = [];

  List<TypeModel> get items {
    return [..._items];
  }

  Future<void> fetchAndSetTypes() async {
    const url = "${baseUrl}api/estate-types/";
    // try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body);
    final List<TypeModel> types = [];
    extractedData.forEach((type) {
      print(type["icon"].runtimeType);
      final icon;
      if (type["icon"].runtimeType == Null) {
        icon = "";
      } else {
        icon = baseUrl + type["icon"];
      }

      print(icon);

      types.add(
        TypeModel(
            id: type["id"],
            title: type["translations"]["uz"]["title"],
            slug: type["slug"],
            icon: icon,
            backgroundColor: type["background_color"],
            foregroundColor: type["foreground_color"]),
      );
    });
    _items = types;
    print(_items);
    notifyListeners();
    // } catch (error) {
    //   print(error);
    // }
  }
}
