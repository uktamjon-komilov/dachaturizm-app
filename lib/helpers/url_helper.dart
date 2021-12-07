import 'package:dachaturizm/constants.dart';

String fixMediaUrl(String url) {
  if (url.contains("https://") || url.contains("http://")) {
    return url;
  }
  return baseUrl.substring(0, baseUrl.length - 1) + url;
}
