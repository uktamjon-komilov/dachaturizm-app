import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/static_page_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class StaticPagesProvider extends ChangeNotifier {
  final Dio dio;
  List<StaticPageModel> _pages = [];

  StaticPagesProvider({required this.dio});

  List<StaticPageModel> get pages {
    return [..._pages];
  }

  // Get static pages
  Future getStaticPages() async {
    List<StaticPageModel> pages = [];
    const url = "${baseUrl}api/staticpages/";
    final response = await dio.get(url);
    await response.data.forEach((item) async {
      StaticPageModel page = await StaticPageModel.fromJson(item);
      pages.add(page);
    });
    _pages = pages;
    notifyListeners();
  }
}
