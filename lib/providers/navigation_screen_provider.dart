import 'package:flutter/cupertino.dart';

class NavigationScreenProvider extends ChangeNotifier {
  int _currentIndex = 0;
  Map<String, dynamic> _data = {};

  int get currentIndex {
    final currentIndex = _currentIndex;
    return currentIndex;
  }

  Map<String, dynamic> get data {
    return {..._data};
  }

  changePageIndex(int index) {
    _currentIndex = index;
    if (index == 0) clearData();
    notifyListeners();
  }

  visitSearchPage(String term) {
    _data = {
      "search_term": term,
    };
    changePageIndex(1);
  }

  clearData() {
    _data = {};
  }
}
