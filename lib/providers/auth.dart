import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class AuthProvider extends ChangeNotifier {
  String _accessToken = "";
  int _userId = 0;

  Future<void> signUp(String phone, String password) async {
    const url = "${baseUrl}api/users/";
    final response = await http.post(Uri.parse(url),
        body: json.encode({"phone": phone, "password": password}));
    print(response.body);
  }
}
