import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationScreenProvider with ChangeNotifier {
  int _currentIndex = 0;
  List<int> _authRequiredScreens = [];
  Map<String, dynamic> _data = {};
  bool _refreshHomePage = false;

  int get currentIndex {
    final currentIndex = _currentIndex;
    return currentIndex;
  }

  bool get refreshHomePage {
    return _refreshHomePage;
  }

  set refreshHomePage(bool value) {
    _refreshHomePage = value;
    if (_refreshHomePage) {
      notifyListeners();
    }
  }

  Map<String, dynamic> get data {
    return {..._data};
  }

  changePageIndex(int index, [Function? callback]) {
    if (index == 0) {
      _refreshHomePage = true;
    }
    if (!_authRequiredScreens.contains(index)) {
      _currentIndex = index;

      notifyListeners();
    } else {
      callback != null ? callback() : null;
      notifyListeners();
    }
    if (index == 0) clearData();
  }

  visitSearchPage(String term) {
    _data = {
      "search_term": term,
    };
    notifyListeners();
    changePageIndex(1);
  }

  clearData() {
    _data = {};
  }
}
