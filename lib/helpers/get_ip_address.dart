import "package:dio/dio.dart";

Future getPublicIP(Dio dio) async {
  try {
    const url = "https://api.ipify.org";
    var response = await dio.get(url);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      print(response.statusCode);
      print(response.data);
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}
