import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationScreenProvider with ChangeNotifier {
  // final AuthProvider auth;
  // NavigationScreenProvider({required this.auth});

  int _currentIndex = 0;
  List<int> _authRequiredScreens = [];
  Map<String, dynamic> _data = {};

  int get currentIndex {
    final currentIndex = _currentIndex;
    return currentIndex;
  }

  Map<String, dynamic> get data {
    return {..._data};
  }

  changePageIndex(int index, [Function? callback]) {
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
