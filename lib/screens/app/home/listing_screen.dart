import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/no_result.dart';
import 'package:dachaturizm/components/search_bar_with_filter.dart';
import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/cards_block.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EstateListingScreen extends StatefulWidget {
  const EstateListingScreen({Key? key}) : super(key: key);

  static const String routeName = "/estate-listing";

  @override
  State<EstateListingScreen> createState() => _EstateListingScreenState();
}

class _EstateListingScreenState extends State<EstateListingScreen> {
  bool _isLoading = true;
  bool _paginationLoading = false;
  bool _isInit = true;
  bool _showTop = true;
  CategoryModel? _category;

  List? _topEstates;
  List? _simpleEstates;
  List? _currentEstates;

  String? _topNextLink;
  String? _simpleNextLink;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      _category = ModalRoute.of(context)!.settings.arguments as CategoryModel;
      await _refreshAction();
      await _listenScroller(context);
    }
  }

  Future<void> _listenScroller(BuildContext context) async {
    _scrollController.addListener(() {
      ScrollPosition position = _scrollController.position;
      if (position.pixels > position.maxScrollExtent - 80 &&
          !_paginationLoading) {
        if (_showTop && _topNextLink != null) {
          setState(() {
            _paginationLoading = true;
          });
          Provider.of<EstateProvider>(context, listen: false)
              .getNextPage(_topNextLink as String)
              .then((value) {
            setState(() {
              _topEstates!.addAll(value["estates"]);
              _paginationLoading = false;
              _topNextLink = value["next"];
            });
          });
        } else if (!_showTop && _simpleNextLink != null) {
          setState(() {
            _paginationLoading = true;
          });
          Provider.of<EstateProvider>(context, listen: false)
              .getNextPage(_simpleNextLink as String)
              .then((value) {
            setState(() {
              _simpleEstates!.addAll(value["estates"]);
              _paginationLoading = false;
              _simpleNextLink = value["next"];
            });
          });
        }
      }
    });
  }

  _search() async {
    Provider.of<EstateProvider>(context, listen: false).getSearchedResults(
        term: _searchController.text,
        category: _category,
        extraArgs: {
          "top": _showTop,
          "simple": !_showTop,
        }).then((data) {
      if (_showTop) {
        setState(() {
          _topEstates = data["estates"];
          _currentEstates = _topEstates;
        });
      } else {
        setState(() {
          _simpleEstates = data["estates"];
          _currentEstates = _simpleEstates;
        });
      }
    });
  }

  Future<void> _refreshAction() async {
    _searchController.text = "";
    await Future.wait([
      Provider.of<EstateProvider>(context, listen: false)
          .getEstatesByType(_category, "top")
          .then((value) {
        setState(() {
          _topEstates = value["estates"];
          _topNextLink = value["next"];
        });
      }),
      Provider.of<EstateProvider>(context, listen: false)
          .getEstatesByType(_category, "simple")
          .then((value) {
        setState(() {
          _simpleEstates = value["estates"];
          _simpleNextLink = value["next"];
        });
      }),
    ]);
    setState(() {
      _currentEstates = _topEstates;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .refreshHomePage = true;
        Provider.of<EstateProvider>(context, listen: false).filtersClear();
        return true;
      },
      child: Scaffold(
        appBar: buildNavigationalAppBar(context, _category!.title, () {
          Provider.of<NavigationScreenProvider>(context, listen: false)
              .refreshHomePage = true;
        }, [
          IconButton(
            onPressed: () => _refreshAction(),
            icon: Icon(Icons.refresh_rounded),
            color: greyishLight,
          ),
        ]),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _refreshAction,
                child: Container(
                  height:
                      (_topEstates!.length == 0 && _simpleEstates!.length == 0)
                          ? 100.h - 4 * defaultPadding
                          : null,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding),
                          child: SearchBarWithFilter(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onSubmit: (value) {
                              if (value != "") {
                                _search();
                              }
                            },
                            onFilterCallback: () => _search(),
                          ),
                        ),
                        Visibility(
                          visible: _currentEstates!.length > 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                            child: Row(
                              children: [
                                SmallButton("Top", enabled: _showTop,
                                    onPressed: () {
                                  setState(() {
                                    _showTop = true;
                                    _currentEstates = _topEstates;
                                  });
                                }),
                                SmallButton("Oddiy", enabled: !_showTop,
                                    onPressed: () {
                                  setState(() {
                                    _showTop = false;
                                    _currentEstates = _simpleEstates;
                                  });
                                }),
                              ],
                            ),
                          ),
                        ),
                        buildCardsBlock(context, _currentEstates),
                        Visibility(
                          visible: _currentEstates!.length == 0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              2 * defaultPadding,
                              100,
                              2 * defaultPadding,
                              0,
                            ),
                            child: NoResult(),
                          ),
                        ),
                        SizedBox(height: defaultPadding),
                        Visibility(
                          visible: _paginationLoading,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 20),
                            height: 60,
                            child: Center(
                              child: SpinKitFadingCircle(
                                color: normalOrange,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: buildBottomNavigation(context, () {
          Navigator.of(context).pop();
        }),
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
