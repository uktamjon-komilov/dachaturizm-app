import 'dart:convert';
import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/no_result.dart';
import 'package:dachaturizm/components/search_bar_with_filter.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class SearchPageScreen extends StatefulWidget {
  const SearchPageScreen({Key? key}) : super(key: key);

  @override
  _SearchPageScreenState createState() => _SearchPageScreenState();
}

class _SearchPageScreenState extends State<SearchPageScreen> {
  bool _isLoading = false;
  bool _paginationLoading = false;
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  List<EstateModel> _results = [];
  String? _nextPage;

  void _saveSearchTerm(String term) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var searchedTerms = prefs.getString("searchedTerms");
    if (searchedTerms != null && searchedTerms != "") {
      List<String> data = json.decode(searchedTerms);
      data.insert(0, term);
      if (data.length > 3) {
        data = data.sublist(0, 3);
      }
      searchedTerms = json.encode(data);
      prefs.setString("searchedTerms", searchedTerms);
    } else {
      List<String> data = [term];
      searchedTerms = json.encode(data);
      prefs.setString("searchedTerms", searchedTerms);
    }
  }

  void _removeSearchTerm(String term) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var searchedTerms = prefs.getString("searchedTerms");
    if (searchedTerms != null && searchedTerms != "") {
      List<String> data = json.decode(searchedTerms);
      data.remove(term);
      searchedTerms = json.encode(data);
      prefs.setString("searchedTerms", searchedTerms);
    }
  }

  Future<List<String>> _getSearchedTerms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var searchedTerms = prefs.getString("searchedTerms");
    if (searchedTerms != null && searchedTerms != "") {
      List<String> data = json.decode(searchedTerms);
      return data;
    } else {
      return [];
    }
  }

  Future _search(context, value) async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<EstateProvider>(context, listen: false)
        .getSearchedResults(term: value)
        .then((value) {
      setState(() {
        _results = value["estates"];
        _nextPage = value["next"];
        _isLoading = false;
      });
    });
  }

  Future<void> _listenScroller(BuildContext context) async {
    _scrollController.addListener(() {
      ScrollPosition position = _scrollController.position;
      if (position.pixels > position.maxScrollExtent - 80 &&
          !_paginationLoading) {
        if (_nextPage != null) {
          setState(() {
            _paginationLoading = true;
          });
          Provider.of<EstateProvider>(context, listen: false)
              .getNextPage(_nextPage as String)
              .then((value) {
            setState(() {
              _results.addAll(value["estates"]);
              _paginationLoading = false;
              _nextPage = value["next"];
            });
          });
        }
      }
    });
  }

  Future<void> _refreshAction() async {
    _searchController.text = "";
    setState(() {
      _results = [];
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    Future.delayed(Duration.zero).then((_) {
      _listenScroller(context);
    });
    String term =
        Provider.of<NavigationScreenProvider>(context).data["search_term"];
    if (term.length > 0) {
      _searchController.text = term;
      await _search(context, term);
      Provider.of<NavigationScreenProvider>(context, listen: false)
          .clearSearch();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .refreshHomePage = true;
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(0);
        return true;
      },
      child: Container(
        height: (_results.length == 0) ? 100.h - 4 * defaultPadding : null,
        padding: EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            Visibility(
              visible: !_isLoading,
              child: SearchBarWithFilter(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: false,
                onSubmit: (value) {
                  if (value == "") {
                    _refreshAction();
                  } else {
                    _search(context, value);
                  }
                },
                onFilterCallback: () =>
                    _search(context, _searchController.text),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Container(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ((_results.length == 0)
                      ? Visibility(
                          visible: _results.length == 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              2 * defaultPadding,
                              100,
                              2 * defaultPadding,
                              0,
                            ),
                            child: NoResult(),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: defaultPadding / 2,
                              ),
                              child: Text(
                                Locales.string(
                                  context,
                                  "search_results",
                                ),
                                style: TextStyles.display2(),
                              ),
                            ),
                            Expanded(
                              child: NotificationListener<
                                  OverscrollIndicatorNotification>(
                                onNotification: (OverscrollIndicatorNotification
                                    overScroll) {
                                  overScroll.disallowGlow();
                                  return false;
                                },
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Wrap(
                                    children: [
                                      ..._results
                                          .map((estate) =>
                                              EstateCard(estate: estate))
                                          .toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _paginationLoading,
                              child: Container(
                                height: 80,
                                padding: EdgeInsets.symmetric(
                                  vertical: defaultPadding,
                                ),
                                child: Center(
                                  child: SpinKitFadingCircle(
                                    color: normalOrange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
