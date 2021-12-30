import 'package:dio/dio.dart';

class BaseRepository {
  bool isSuccessStatus(Response response) {
    return (response.statusCode as int >= 200 ||
        response.statusCode as int < 300);
  }
}
