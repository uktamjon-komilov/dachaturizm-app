import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationScreenProvider with ChangeNotifier {
  final AuthProvider auth;
  int _currentIndex = 0;
  List<int> _authRequiredScreens = [2, 3];
  Map<String, dynamic> _data = {
    "search_term": "",
  };
  bool _refreshHomePage = false;
  bool _refreshChatsScreen = false;
  bool _refreshUserScreen = false;
  bool _recreateCreateEstateScreen = false;
  int _unreadMessagesCount = 0;
  Map<String, dynamic> extraPageData = {"home": {}};

  NavigationScreenProvider({required this.auth});

  int get currentIndex {
    final currentIndex = _currentIndex;
    return currentIndex;
  }

  bool get recreateCreateEstateScreen {
    return _recreateCreateEstateScreen;
  }

  bool get refreshHomePage {
    return _refreshHomePage;
  }

  bool get refreshChatsScreen {
    return _refreshChatsScreen;
  }

  set setHomeData(Map<String, dynamic> data) {
    extraPageData["home"] = data;
  }

  set refreshHomePage(bool value) {
    _refreshHomePage = value;
    if (_refreshHomePage) {
      notifyListeners();
    }
  }

  dispatchRecreateCreateEstateScreen(bool value) {
    _recreateCreateEstateScreen = value;
    if (value) {
      notifyListeners();
    }
  }

  set refreshChatsScreen(bool value) {
    _refreshChatsScreen = value;
    if (_refreshChatsScreen) {
      notifyListeners();
    }
  }

  get unreadMessagesCount {
    return _unreadMessagesCount;
  }

  set unreadMessagesCount(value) {
    _unreadMessagesCount = value;
    notifyListeners();
  }

  Map<String, dynamic> get data {
    return {..._data};
  }

  changePageIndex(int index, [Function? callback]) async {
    if (index == 0) {
      _refreshHomePage = true;
    } else if (index == 3) {
      _refreshChatsScreen = true;
    } else if (index == 4) {
      _refreshUserScreen = true;
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
  }

  visitSearchPage(String term) async {
    _data["search_term"] = term;
    await changePageIndex(1);
  }

  clearSearch() {
    _data["search_term"] = "";
  }
}
