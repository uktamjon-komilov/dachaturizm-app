import 'dart:convert';
import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/no_result.dart';
import 'package:dachaturizm/components/search_bar_with_filter.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/search/filters_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:path/path.dart';
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
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();

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

  Future<void> _search(context, value) async {
    Map<String, dynamic> filters =
        Provider.of<EstateProvider>(context, listen: false).searchFilters;
    setState(() {
      _isLoading = true;
    });
    Provider.of<EstateProvider>(context, listen: false)
        .searchAll(term: value)
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _unsearch(context) async {
    Provider.of<EstateProvider>(context, listen: false).unsetSearchedResults();
    FocusScope.of(context).requestFocus(_searchFocusNode);
  }

  Future<void> _refreshAction() async {
    _searchController.text = "";
    _unsearch(context);
  }

  @override
  Widget build(BuildContext context) {
    List<EstateModel> allEstates =
        Provider.of<EstateProvider>(context, listen: false).searchedAllEstates;
    Map<String, dynamic> data =
        Provider.of<NavigationScreenProvider>(context).data;
    String term = data.containsKey("search_term") ? data["search_term"] : "";

    bool hasFilters =
        Provider.of<EstateProvider>(context, listen: false).hasFilters;

    if (term != "") {
      Provider.of<NavigationScreenProvider>(context, listen: false).clearData();
      _searchController.text = term;
      _search(context, term);
    }

    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .refreshHomePage = true;
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(0);
        return true;
      },
      child: Container(
        height: (allEstates.length == 0) ? 100.h - 4 * defaultPadding : null,
        padding: EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            _isLoading
                ? Container()
                : SearchBarWithFilter(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: false,
                    onSubmit: (value) {
                      _search(context, value);
                    },
                    onChange: (value) {
                      Provider.of<NavigationScreenProvider>(context,
                              listen: false)
                          .clearData();
                      if (value == "") {
                        _refreshAction();
                      }
                    },
                  ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _isLoading
                        ? Container(
                            height: 100,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : ((allEstates.length == 0)
                            ? Visibility(
                                visible: allEstates.length == 0,
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
                                        vertical: defaultPadding / 2),
                                    child: Text(
                                      Locales.string(
                                        context,
                                        "search_results",
                                      ),
                                      style: TextStyles.display2(),
                                    ),
                                  ),
                                  Wrap(
                                    children: [
                                      ...allEstates
                                          .map((estate) =>
                                              EstateCard(estate: estate))
                                          .toList()
                                    ],
                                  ),
                                ],
                              )),
                  ],
                ),
              ),
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
