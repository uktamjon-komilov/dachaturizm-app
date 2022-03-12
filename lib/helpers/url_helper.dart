import 'package:dachaturizm/constants.dart';

String fixMediaUrl(String url) {
  print(url);
  print(url.runtimeType);
  if (url.contains("https://") || url.contains("http://")) {
    return url;
  }
  return baseUrl.substring(0, baseUrl.length - 1) + url;
}
