import 'dart:convert';

import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/search_bar.dart';
import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/type_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EstateListingScreen extends StatefulWidget {
  const EstateListingScreen({Key? key}) : super(key: key);

  static const routeName = "/estate-listing";

  @override
  State<EstateListingScreen> createState() => _EstateListingScreenState();
}

class _EstateListingScreenState extends State<EstateListingScreen> {
  bool _isLoading = false;
  bool _isSearched = false;
  // GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshAction();
  }
  // @override
  // void didChangeDependencies() {
  //   _refreshAction();
  //   super.didChangeDependencies();
  // }

  Future<void> _refreshAction() async {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero).then((_) {
      Provider.of<EstateProvider>(context, listen: false)
          .fetchAllAndSetEstates()
          .then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    });
    _searchController.text = "";
    _unsearch();
  }

  Future<void> _search(slug, value) async {
    setState(() {
      _isLoading = true;
    });
    Provider.of<EstateProvider>(context, listen: false)
        .searchTop(slug, term: value)
        .then((_) {
      Provider.of<EstateProvider>(context, listen: false)
          .searchSimple(slug, term: value)
          .then((_) {
        setState(() {
          _isLoading = false;
          _isSearched = true;
        });
      });
    });
  }

  void _unsearch() {
    Provider.of<EstateProvider>(context, listen: false).unsetSearchedResults();
    setState(() {
      _isSearched = false;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    final int screenWidth = queryData.size.width.toInt();
    final int screenHeight = queryData.size.height.toInt();

    final int estateTypeId = ModalRoute.of(context)!.settings.arguments as int;
    final List topEstates = _isSearched
        ? Provider.of<EstateProvider>(context).searchedTopEstates
        : Provider.of<EstateProvider>(context, listen: false)
            .getEstatesByType(estateTypeId, top: true);
    final List simpleEstates = _isSearched
        ? Provider.of<EstateProvider>(context).searchedSimpleEstates
        : Provider.of<EstateProvider>(context, listen: false)
            .getEstatesByType(estateTypeId);
    final estateType = Provider.of<EstateTypesProvider>(context, listen: false)
        .getType(estateTypeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(Locales.string(context, "types")),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshAction,
              child: Container(
                // decoration: BoxDecoration(color: normalOrange),
                height: (topEstates.length == 0 && simpleEstates.length == 0)
                    ? screenHeight - 4 * defaultPadding
                    : null,
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
                        estateType != null ? estateType.title : "",
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: defaultPadding,
                      ),
                      SearchBar(
                        controller: _searchController,
                        onSubmit: (value) {
                          _search(
                              estateType != null ? estateType.slug : "dacha",
                              value);
                        },
                        onChange: (value) {
                          if (value == "") {
                            _refreshAction();
                          }
                        },
                      ),
                      (topEstates.length == 0 && simpleEstates.length == 0)
                          ? Container(
                              height: 100,
                              child: Center(
                                child:
                                    Text(Locales.string(context, "no_results")),
                              ),
                            )
                          : (topEstates.length > 0)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: defaultPadding / 2),
                                      child: Text1(Locales.string(
                                          context, "top_estates")),
                                    ),
                                    Wrap(
                                      children: [
                                        ...topEstates
                                            .map((estate) => EstateCard(
                                                screenWidth: screenWidth,
                                                estate: estate))
                                            .toList()
                                      ],
                                    ),
                                  ],
                                )
                              : Container(),
                      (simpleEstates.length > 0)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: defaultPadding / 2),
                                  child: Text1(Locales.string(
                                      context, "simple_estates")),
                                ),
                                Wrap(
                                  children: [
                                    ...simpleEstates
                                        .map((estate) => EstateCard(
                                            screenWidth: screenWidth,
                                            estate: estate))
                                        .toList()
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}