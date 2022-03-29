import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/components/no_result.dart';
import 'package:dachaturizm/components/search_bar_with_filter.dart';
import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/remove_doubles.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/cards_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
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
  bool _showTop = false;
  CategoryModel? _category;

  List<EstateModel> _allEstates = [];
  List<EstateModel> _topEstates = [];
  List<EstateModel> _currentEstates = [];

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
            List<EstateModel> _estates = value["estates"];
            _estates.shuffle();
            _topEstates.addAll(_estates);
            _topEstates = removeDoubleEstates(_topEstates);
            _topNextLink = value["next"];
            setState(() {
              _currentEstates = _topEstates;
              _paginationLoading = false;
            });
          });
        } else if (
            !_showTop &&
            _simpleNextLink != null) {
          setState(() {
            _paginationLoading = true;
          });
          Provider.of<EstateProvider>(context, listen: false)
              .getNextPage(_simpleNextLink as String)
              .then((value) {
            List<EstateModel> _estates = value["estates"];
            _estates.shuffle();
            _allEstates.addAll(_estates);
            _allEstates = removeDoubleEstates(_allEstates);
            _simpleNextLink = value["next"];
            setState(() {
              _currentEstates = _allEstates;
              _paginationLoading = false;
            });
          });
        }
      }
    });
  }

  _search() async {
    _allEstates = [];
    await Future.wait([
      Provider.of<EstateProvider>(context, listen: false).getSearchedResults(
          term: _searchController.text,
          category: _category,
          extraArgs: {
            "top": true,
            "simple": false,
          }).then((data) {
        List<EstateModel> _estates = data["estates"];
        _estates.shuffle();
        _topEstates = removeDoubleEstates(_estates);
        setState(() {
          _topNextLink = data["next"];
        });
      }),
      Provider.of<EstateProvider>(context, listen: false).getSearchedResults(
          term: _searchController.text,
          category: _category,
          extraArgs: {
            "all": true,
          }).then((data) {
        List<EstateModel> _estates = data["estates"];
        _estates.shuffle();
        _allEstates = removeDoubleEstates(_estates);
        setState(() {
          _simpleNextLink = data["next"];
        });
      }),
    ]).then((_) {
      if (_showTop) {
        setState(() {
          _currentEstates = _topEstates;
        });
      } else {
        setState(() {
          _currentEstates = _allEstates;
        });
      }
    });
  }

  Future<void> _refreshAction() async {
    _searchController.text = "";
    _allEstates = [];
    await Future.wait([
      Provider.of<EstateProvider>(context, listen: false)
          .getEstatesByType(_category, "top")
          .then((value) {
        List<EstateModel> _estates = value["estates"];
        _estates.shuffle();
        _estates = removeDoubleEstates(_estates);
          _topEstates = _estates;
        setState(() {
          _topNextLink = value["next"];
        });
      }),
      Provider.of<EstateProvider>(context, listen: false)
          .getEstatesByType(_category, "all")
          .then((value) {
        List<EstateModel> _estates = value["estates"];
        _estates.shuffle();
        _estates = removeDoubleEstates(_estates);
          _allEstates = _estates;
        setState(() {
          _simpleNextLink = value["next"];
        });
      }),
    ]);
    setState(() {
      _isLoading = false;
      if (_showTop) {
        _currentEstates = _topEstates;
      } else {
        _currentEstates = _allEstates;
      }
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
                  height: 100.h,
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
                          visible: _allEstates.length > 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                            child: Row(
                              children: [
                                SmallButton(Locales.string(context, "all"),
                                    enabled: !_showTop, onPressed: () {
                                  setState(() {
                                    _showTop = false;
                                    _currentEstates = _allEstates;
                                  });
                                }),
                                SmallButton(Locales.string(context, "top"),
                                    enabled: _showTop, onPressed: () {
                                  setState(() {
                                    _showTop = true;
                                    _currentEstates = _topEstates;
                                  });
                                }),
                              ],
                            ),
                          ),
                        ),
                        _currentEstates.length > 0
                            ? buildCardsBlock(context, _currentEstates)
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  2 * defaultPadding,
                                  100,
                                  2 * defaultPadding,
                                  0,
                                ),
                                child: NoResult(),
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
