import "package:dio/dio.dart";

Future getPublicIP(Dio dio) async {
  try {
    const url = "https://api.ipify.org";
    Response response = await dio.get(url);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
