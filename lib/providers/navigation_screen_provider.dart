import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationScreenProvider with ChangeNotifier {
  final AuthProvider auth;
  int _currentIndex = 0;
  List<int> _authRequiredScreens = [2, 3];
  Map<String, dynamic> _data = {};
  bool _refreshHomePage = false;
  bool _refreshChatsScreen = false;

  NavigationScreenProvider({required this.auth});

  int get currentIndex {
    final currentIndex = _currentIndex;
    return currentIndex;
  }

  bool get refreshHomePage {
    return _refreshHomePage;
  }

  bool get refreshChatsScreen {
    return _refreshChatsScreen;
  }

  set refreshHomePage(bool value) {
    _refreshHomePage = value;
    if (_refreshHomePage) {
      notifyListeners();
    }
  }

  set refreshChatsScreen(bool value) {
    _refreshChatsScreen = value;
    if (_refreshChatsScreen) {
      notifyListeners();
    }
  }

  Map<String, dynamic> get data {
    return {..._data};
  }

  changePageIndex(int index, [Function? callback]) async {
    if (index == 0) {
      _refreshHomePage = true;
    } else if (index == 3) {
      _refreshChatsScreen = true;
    }
    if (!_authRequiredScreens.contains(index)) {
      _currentIndex = index;
      notifyListeners();
    } else {
      String access = await auth.getAccessToken();
      if (access == "") {
        callback != null ? callback() : null;
      } else {
        _currentIndex = index;
      }
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
