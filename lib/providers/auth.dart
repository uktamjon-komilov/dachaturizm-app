import 'dart:convert';

import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class AuthProvider extends ChangeNotifier {
  String _accessToken = "";
  int _userId = 0;

  Future<Map<String, dynamic>> checkUser(String phone) async {
    const url = "${baseUrl}api/sms/send-message/";
    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"phone": phone}));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      return json.decode(response.body);
    }
    return {"status": false};
  }

  Future<Map<String, dynamic>> checkCode(String phone, String code) async {
    const url = "${baseUrl}api/sms/verify/";
    final response = await http.post(Uri.parse(url),
        headers: {"Content-type": "application/json"},
        body: json.encode({"phone": phone, "code": code}));
    if (response.statusCode >= 200 || response.statusCode < 300) {
      return json.decode(response.body);
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
      return json.decode(response.body);
    }
    return {"status": false};
  }
}
