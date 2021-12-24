import 'dart:convert';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthProvider with ChangeNotifier {
  final Dio dio;
  String _accessToken = "";
  String _refreshToken = "";
  int _userId = 0;
  UserModel? _user;

  AuthProvider({required this.dio});

  bool get isAuthenticated {
    return false;
  }

  int get userId {
    return _userId;
  }

  UserModel? get user {
    if (_accessToken == "" || _accessToken == null) {
      _user = null;
    }
    return _user;
  }

  dynamic getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String access = prefs.getString("access").toString();
    var expiryDateString = prefs.getString("access_expires");
    if (expiryDateString == null || expiryDateString == "") {
      return "";
    }
    DateTime expiryDate = DateTime.parse(expiryDateString.toString());
    DateTime now = DateTime.now();
    if (expiryDate.isAfter(now)) {
      return access;
    } else {
      await refresh();
      String access = prefs.getString("access").toString();
      _userId = Jwt.parseJwt(access)["user_id"];
      return access;
    }
  }

  dynamic getUserId() async {
    if (_userId != 0) {
      final result = _userId;
      return result;
    }
    final access = await getAccessToken();
    if (access == "") {
      return null;
    }
    _accessToken = access;
    Map payload = Jwt.parseJwt(_accessToken);
    return payload["user_id"];
  }

  Future<Map<String, dynamic>> checkUser(String phone) async {
    const url = "${baseUrl}api/sms/send-message/";
    final response = await dio.post(
      url,
      options: Options(
        headers: {"Content-Type": "application/json"},
      ),
      data: json.encode({"phone": phone}),
    );
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      return response.data;
    }
    return {"status": false};
  }

  Future<Map<String, dynamic>> checkCode(String phone, String code) async {
    const url = "${baseUrl}api/sms/verify/";
    final response = await dio.post(
      url,
      options: Options(headers: {"Content-type": "application/json"}),
      data: json.encode({"phone": phone, "code": code}),
    );
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      return response.data;
    }
    return {"status": false};
  }

  Future<Map<String, dynamic>> signUp(
      String phone, String password, String firstName, String lastName) async {
    const url = "${baseUrl}api/users/";
    final response = await dio.post(
      url,
      options: Options(
        headers: {"Content-type": "application/json"},
      ),
      data: json.encode({
        "phone": phone,
        "password": password,
        "first_name": firstName,
        "last_name": lastName
      }),
    );
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      return response.data;
    }
    return {"status": false};
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    const url = "${baseUrl}api/token/";
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {"Content-type": "application/json"},
        ),
        data: {"phone": phone, "password": password},
      );

      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final data = response.data;
        if (data.containsKey("access")) {
          _accessToken = data["access"] as String;
          _refreshToken = data["refresh"] as String;
          await prefs.setString("access", _accessToken);
          await prefs.setString("refresh", _refreshToken);
          final expiryDate = DateTime.now().add(Duration(minutes: 59));
          print(expiryDate.toString());
          await prefs.setString("access_expires", expiryDate.toString());
          Map<String, dynamic> payload = Jwt.parseJwt(data["access"]);
          _userId = payload["user_id"];
          return data;
        }
      }
    } catch (e) {
      // await logout();
      print("debugging");
      print(e);
    }
    return {"status": false};
  }

  Future<String> refresh() async {
    const url = "${baseUrl}api/token/refresh/";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _refresh = prefs.getString("refresh").toString();
    if (_refresh == "") {
      _accessToken = "";
      _refreshToken = "";
      prefs.setString("access", "");
      prefs.setString("refresh", "");
      prefs.setString("access_expires", "");
    }
    try {
      final response = await dio.post(
        url,
        options: Options(
          headers: {"Content-type": "application/json"},
        ),
        data: json.encode({"refresh": _refresh}),
      );
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        final data = response.data;
        prefs.setString("access", data["access"]);
        final expiryDate = DateTime.now().add(Duration(minutes: 59));
        prefs.setString("access_expires", expiryDate.toString());
        return data["access"];
      }
    } catch (e) {}
    return "";
  }

  Future logout() async {
    _accessToken = "";
    _refreshToken = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("access", "");
    prefs.setString("refresh", "");
    prefs.setString("access_expires", "");
    notifyListeners();
  }

  Future<Map> updateUser(FormData data) async {
    final userId = await getUserId();
    final access = await getAccessToken();
    final url = "${baseUrl}api/users/${userId}/";
    try {
      final response = await dio.patch(
        url,
        data: data,
        options: Options(
          headers: {
            "Content-type": "multipart/form-data",
            "Authorization": "Bearer ${access}"
          },
        ),
      );
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        return response.data;
      }
    } catch (e) {
      print(e);
    }
    return {"status": false};
  }

  Future getUserData() async {
    int userId = await getUserId();
    if (userId != null) {
      final url = "${baseUrl}api/users/${userId}/";
      final response = await dio.get(url);
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        Map<String, dynamic> data = response.data;
        print(data);
        _user = UserModel.fromJson(data);
        notifyListeners();
        return _user;
      }
    }

    return {"status": false};
  }
}
