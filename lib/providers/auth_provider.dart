import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String _accessToken = "";
  int _userId = 0;

  bool get isAuthenticated {
    return token != null;
  }

  get token {
    if (_accessToken != "") {
      return _accessToken;
    }
    return null;
  }

  Future<Map<String, dynamic>> checkUser(String phone) async {
    const url = "${baseUrl}api/sms/send-message/";
    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"phone": phone}));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return {"status": false};
  }

  Future<Map<String, dynamic>> checkCode(String phone, String code) async {
    const url = "${baseUrl}api/sms/verify/";
    final response = await http.post(Uri.parse(url),
        headers: {"Content-type": "application/json"},
        body: json.encode({"phone": phone, "code": code}));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return {"status": false};
  }

  Future<Map<String, dynamic>> signUp(
      String phone, String password, String firstName, String lastName) async {
    const url = "${baseUrl}api/users/";
    final response = await http.post(Uri.parse(url),
        headers: {"Content-type": "application/json"},
        body: json.encode({
          "phone": phone,
          "password": password,
          "first_name": firstName,
          "last_name": lastName
        }));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    return {"status": false};
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    const url = "${baseUrl}api/token/";
    final response = await http.post(Uri.parse(url),
        headers: {"Content-type": "application/json"},
        body: json.encode({"phone": phone, "password": password}));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("userData", utf8.decode(response.bodyBytes));
      final data = json.decode(utf8.decode(response.bodyBytes));
      // print(data);
      if (data.containsKey("access")) {
        _accessToken = data["access"] as String;
        print(_accessToken);
        // _userId = data["user_id"];
        notifyListeners();
        return data;
      }
    }
    return {"status": false};
  }
}
