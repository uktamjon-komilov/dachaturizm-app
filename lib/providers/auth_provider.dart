import 'dart:convert';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/message_model.dart';
import 'package:dachaturizm/models/transaction_model.dart';
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
    String refresh = await getRefreshToken();
    if (refresh == "") return "";
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
      await refresh_token();
      String access = prefs.getString("access").toString();
      _userId = Jwt.parseJwt(access)["user_id"];
      return access;
    }
  }

  dynamic getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String refresh = prefs.getString("refresh").toString();
    var expiryDateString = prefs.getString("refresh_expires");
    if (expiryDateString == null || expiryDateString == "") {
      return "";
    }
    DateTime expiryDate = DateTime.parse(expiryDateString.toString());
    DateTime now = DateTime.now();
    if (expiryDate.isAfter(now)) {
      return refresh;
    } else {
      return await logout();
    }
  }

  Future getUserId() async {
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
    print(response);
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
        "phone": phone.toString().replaceAll("+", ""),
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
        data: {
          "phone": phone.toString().replaceAll("+", ""),
          "password": password
        },
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
          final accessExpiryDate = DateTime.now().add(Duration(minutes: 59));
          await prefs.setString("access_expires", accessExpiryDate.toString());
          final refreshExpiryDate =
              DateTime.now().add(Duration(days: 29, hours: 23));
          await prefs.setString(
              "refresh_expires", refreshExpiryDate.toString());
          Map<String, dynamic> payload = Jwt.parseJwt(data["access"]);
          _userId = payload["user_id"];
          return data;
        }
      }
    } catch (e) {
      print("debugging");
      print(e);
    }
    return {"status": false};
  }

  Future<String> refresh_token() async {
    const url = "${baseUrl}api/token/refresh/";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _refresh = prefs.getString("refresh").toString();
    if (_refresh == "") {
      _accessToken = "";
      _refreshToken = "";
      prefs.setString("access", "");
      prefs.setString("refresh", "");
      prefs.setString("access_expires", "");
      prefs.setString("refresh_expires", "");
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
    _userId = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("access", "");
    prefs.setString("refresh", "");
    prefs.setString("access_expires", "");
    prefs.setString("refresh_expires", "");
    notifyListeners();
    return "";
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

  Future<UserModel?> getUserData() async {
    int userId = await getUserId();
    if (userId != null) {
      final url = "${baseUrl}api/users/${userId}/";
      final response = await dio.get(url);
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        Map<String, dynamic> data = response.data;
        _user = UserModel.fromJson(data);
        notifyListeners();
        return _user;
      }
    }

    return null;
  }

  Future<UserModel?> getUserDataWithoutNotifying() async {
    int userId = await getUserId();
    if (userId != null) {
      final url = "${baseUrl}api/users/${userId}/";
      final response = await dio.get(url);
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        Map<String, dynamic> data = response.data;
        _user = UserModel.fromJson(data);
        return _user;
      }
    }

    return null;
  }

  Future getMyChats() async {
    const url = "${baseUrl}api/messages/mychats/";
    String access = await getAccessToken();
    String refresh = await getRefreshToken();
    List<MessageModel> chats = [];
    if (refresh == null || refresh == "") {
      return chats;
    }
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer ${access}"
    };
    final response = await dio.get(url, options: Options(headers: headers));
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      await response.data.forEach((item) async {
        MessageModel chat = await MessageModel.fromJson(item);
        chats.add(chat);
      });
    }
    try {
      return chats;
    } catch (e) {}
    return chats;
  }

  Future getMessages(int estateId, int receiverId) async {
    const url = "${baseUrl}api/messages/get-messages/";
    String access = await getAccessToken();
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer ${access}"
    };
    Map<String, dynamic> data = {"estate": null, "messages": []};
    try {
      final response = await dio.post(url,
          data: {"estate": estateId, "receiver": receiverId},
          options: Options(headers: headers));
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        EstateModel estate =
            await EstateModel.fromJsonAsBanner(response.data["estate"]);
        data["estate"] = estate;
        await response.data["results"].forEach((item) async {
          MessageModel message = await MessageModel.fromJson(item);
          data["messages"].add(message);
        });
      }
    } catch (e) {
      print(e);
    }
    return data;
  }

  Future sendMessage(int estateId, int receiverId, String text) async {
    const url = "${baseUrl}api/messages/send-message/";
    String access = await getAccessToken();
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Authorization": "Bearer ${access}"
    };
    Map<String, dynamic> data = {"estate": null, "messages": []};
    try {
      final response = await dio.post(url,
          data: {"estate": estateId, "receiver": receiverId, "text": text},
          options: Options(headers: headers));
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        EstateModel estate =
            await EstateModel.fromJsonAsBanner(response.data["estate"]);
        data["estate"] = estate;
        await response.data["results"].forEach((item) async {
          MessageModel message = await MessageModel.fromJson(item);
          data["messages"].add(message);
        });
      }
    } catch (e) {
      print(e);
    }
    return data;
  }

  Future<UserModel> getUser(int userId) async {
    final url = "${baseUrl}api/users/${userId}";
    final response = await dio.get(url);
    UserModel user = UserModel.fromJson(response.data);
    return user;
  }

  Future<Map<String, bool>> resetPasswordBase(String url, dynamic data) async {
    Map<String, bool> result = {"status": false};
    try {
      final response = await dio.post(url, data: data);
      if (response.statusCode as int >= 200 ||
          response.statusCode as int < 300) {
        result["status"] = response.data["result"];
      }
    } catch (e) {}
    return result;
  }

  Future<Map<String, bool>> resetPassword1(String phone) async {
    const url = "${baseUrl}api/users/reset-password/step1/";
    Map<String, dynamic> data = {"phone": phone};
    return await resetPasswordBase(url, data);
  }

  Future<Map<String, bool>> resetPassword2(String phone, String code) async {
    const url = "${baseUrl}api/users/reset-password/step2/";
    Map<String, dynamic> data = {"phone": phone, "code": code};
    return await resetPasswordBase(url, data);
  }

  Future<Map<String, bool>> resetPassword3(
      String phone, String code, String newPassword) async {
    const url = "${baseUrl}api/users/reset-password/step3/";
    Map<String, dynamic> data = {
      "phone": phone,
      "code": code,
      "new_password": newPassword
    };
    return await resetPasswordBase(url, data);
  }

  Future<Map<String, dynamic>> renewPassword(
    String oldPassword,
    String newPassword,
  ) async {
    String access = await getAccessToken();
    const url = "${baseUrl}api/users/renew-password/";
    Map<String, dynamic> data = {
      "old_password": oldPassword,
      "new_password": newPassword
    };
    Map<String, String> headers = {"Authorization": "Bearer ${access}"};
    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      print(e);
    }
    return {"status": false, "detail": "BASE_ERROR"};
  }

  Future<List<TransactionModel>> getTransactions(String type) async {
    List<TransactionModel> transactions = [];
    final url = "${baseUrl}api/transactions/${type}/";
    String access = await getAccessToken();
    Map<String, String> headers = {"Authorization": "Bearer ${access}"};
    try {
      final response = await dio.get(url, options: Options(headers: headers));
      response.data.forEach((item) {
        transactions.add(TransactionModel.fromJson(item));
      });
    } catch (e) {}
    return transactions;
  }

  Future sendFeedback(String phone, String name, String text) async {
    const url = "${baseUrl}api/feedback/";
    print(url);
    final response =
        await dio.post(url, data: {"phone": phone, "name": name, "text": text});
    print(response);
    if (response.statusCode as int >= 200 || response.statusCode as int < 300) {
      return true;
    }
    return false;
  }
}
