import 'dart:convert';

import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/search_bar.dart';
import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPageScreen extends StatefulWidget {
  const SearchPageScreen({Key? key}) : super(key: key);

  @override
  _SearchPageScreenState createState() => _SearchPageScreenState();
}

class _SearchPageScreenState extends State<SearchPageScreen> {
  bool _isLoading = false;
  bool _isSearched = false;
  TextEditingController _searchController = TextEditingController();

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

  Future<void> _search(value) async {
    setState(() {
      _isLoading = true;
    });
    Provider.of<EstateProvider>(context, listen: false)
        .searchAll(term: value)
        .then((_) {
      setState(() {
        _isLoading = false;
        _isSearched = true;
      });
    });
  }

  void _unsearch() {
    Provider.of<EstateProvider>(context, listen: false).unsetSearchedResults();
    setState(() {
      _isSearched = false;
    });
  }

  Future<void> _refreshAction() async {
    _searchController.text = "";
    _unsearch();
  }

  @override
  Widget build(BuildContext context) {
    List<EstateModel> allEstates =
        Provider.of<EstateProvider>(context, listen: false).searchedAllEstates;

    print(_isLoading);

    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    final int screenWidth = queryData.size.width.toInt();
    final int screenHeight = queryData.size.height.toInt();

    return Container(
      // decoration: BoxDecoration(color: normalOrange),
      height:
          (allEstates.length == 0) ? screenHeight - 4 * defaultPadding : null,
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: defaultPadding,
            ),
            Text(
              Locales.string(context, "search"),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: defaultPadding,
            ),
            SearchBar(
              controller: _searchController,
              autofocus: true,
              onSubmit: (value) {
                _search(value);
              },
              onChange: (value) {
                if (value == "") {
                  _refreshAction();
                }
              },
            ),
            _isLoading
                ? Container(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ((allEstates.length == 0)
                    ? Container(
                        height: 100,
                        child: Center(
                          child: Text(Locales.string(context, "no_results")),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: defaultPadding / 2),
                            child: Text1(
                                Locales.string(context, "search_results")),
                          ),
                          Wrap(
                            children: [
                              ...allEstates
                                  .map((estate) => EstateCard(
                                      screenWidth: screenWidth, estate: estate))
                                  .toList()
                            ],
                          ),
                        ],
                      )),
          ],
        ),
      ),
    );
  }
}
