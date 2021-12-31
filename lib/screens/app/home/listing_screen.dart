import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/no_result.dart';
import 'package:dachaturizm/components/search_bar_with_filter.dart';
import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EstateListingScreen extends StatefulWidget {
  const EstateListingScreen({Key? key}) : super(key: key);

  static const String routeName = "/estate-listing";

  @override
  State<EstateListingScreen> createState() => _EstateListingScreenState();
}

class _EstateListingScreenState extends State<EstateListingScreen> {
  bool _isLoading = true;
  bool _isInit = true;
  bool _showTop = true;
  TypeModel? _estateType;
  List? _topEstates;
  List? _simpleEstates;
  List? _currentEstates;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      await _refreshAction();
      final TypeModel _estateType =
          ModalRoute.of(context)!.settings.arguments as TypeModel;
    }
  }

  Future<void> _refreshAction() async {
    setState(() {
      _isLoading = true;
    });
    // Provider.of<EstateProvider>(context, listen: false)
    //     .fetchAllAndSetEstates()
    //     .then((value) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .refreshHomePage = true;
        return true;
      },
      child: Scaffold(
        appBar: buildNavigationalAppBar(context, _estateType!.title, () {
          Provider.of<NavigationScreenProvider>(context, listen: false)
              .refreshHomePage = true;
        }),
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
                              // _search(
                              //     _estateType != null
                              //         ? _estateType!.slug
                              //         : "dacha",
                              //     value);
                            },
                            onChange: (value) {
                              if (value == "") {
                                _refreshAction();
                              }
                            },
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
                        _buildCardsBlock(context, _currentEstates),
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
    super.dispose();
  }

  Widget _buildCardsBlock(BuildContext context, List? estates) {
    return estates!.length == 0
        ? Container()
        : Container(
            width: 100.w,
            padding: EdgeInsets.fromLTRB(
              defaultPadding,
              0,
              defaultPadding,
              0,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 6,
              children: [
                ...estates.map((estate) => EstateCard(estate: estate)).toList(),
              ],
            ),
          );
  }
}
