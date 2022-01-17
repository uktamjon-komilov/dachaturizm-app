import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/components/text_input.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/models/currency_model.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/models/popular_place_model.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/facility_provider.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:find_dropdown/find_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SearchFilersScreen extends StatefulWidget {
  const SearchFilersScreen({Key? key}) : super(key: key);

  static String routeName = "/filters";

  @override
  _SearchFilersScreenState createState() => _SearchFilersScreenState();
}

class _SearchFilersScreenState extends State<SearchFilersScreen> {
  RangeValues _priceConstraints = RangeValues(0, 10000);
  int? _divisions;
  RangeValues _selectedRange = RangeValues(0, 10000);
  bool _isInit = true;
  bool _isLoading = true;
  List? _sortingTypes;
  String? _currentSort;
  int? _currentCurrencyId;
  String _currentPlace = "";
  List<PopularPlaceModel> _places = [];
  void Function()? onFilterCallback;
  int? _categoryId;

  TextEditingController _addressController = TextEditingController();
  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();

  _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map data = ModalRoute.of(context)!.settings.arguments as Map;
      if (data.containsKey("category")) {
        _categoryId = data["category"];
      }
    } catch (e) {
      print(e);
    }

    await Future.wait([
      Provider.of<FacilityProvider>(context, listen: false).getFacilities(),
      Provider.of<FacilityProvider>(context, listen: false)
          .getPopularPlaces()
          .then((value) {
        _places = value;
      }),
      Provider.of<CurrencyProvider>(context, listen: false)
          .getCurrencies()
          .then((value) async {
        await _changePriceRange(value[0].id);
      }),
    ]);

    _sortingTypes = Provider.of<EstateProvider>(context, listen: false).sorting;
    _currentSort =
        Provider.of<EstateProvider>(context, listen: false).filters["sorting"];
    _addressController.text =
        Provider.of<EstateProvider>(context, listen: false).filters["address"];

    setState(() {
      _isLoading = false;
    });
  }

  _changePriceRange(int? currencyId) async {
    if (currencyId == null) {
      currencyId = _currentCurrencyId;
    }
    await Provider.of<EstateProvider>(context, listen: false)
        .getExtrimalPrices(currencyId as int, categoryId: _categoryId)
        .then((value) {
      setState(() {
        if (currencyId as int < 2) {
          _priceConstraints = RangeValues(0.0, 1200.0);
          _selectedRange = RangeValues(0.0, 1200.0);
          _divisions = 240;
        } else {
          _priceConstraints = RangeValues(0.0, 5000000.0);
          _selectedRange = RangeValues(0.0, 5000000.0);
          _divisions = 250;
        }
        _minPriceController.text = _selectedRange.start.toString();
        _maxPriceController.text = _selectedRange.end.toString();
      });
    });
  }

  _changeCurrency(int id) async {
    setState(() {
      _currentCurrencyId = id;
    });
    await _changePriceRange(_currentCurrencyId);
  }

  _setAllFilters() {
    Provider.of<EstateProvider>(context, listen: false)
        .filtersAddress(_addressController.text);

    if (_currentPlace != "") {
      int _currentPlaceId =
          _places.firstWhere((element) => element.title == _currentPlace).id;
      Provider.of<EstateProvider>(context, listen: false)
          .filtersPlace(_currentPlaceId);
    }

    double maxPrice = double.parse(_maxPriceController.text);
    double minPrice = double.parse(_minPriceController.text);

    if (minPrice < maxPrice) {
      Provider.of<EstateProvider>(context, listen: false)
          .filtersMinPrice(double.parse(_minPriceController.text));
    }

    if (maxPrice != 0.0 && maxPrice > minPrice) {
      Provider.of<EstateProvider>(context, listen: false)
          .filtersMaxPrice(double.parse(_maxPriceController.text));
    }

    Provider.of<EstateProvider>(context, listen: false)
        .filtersSorting(_currentSort as String);

    if (_currentCurrencyId != 0) {
      Provider.of<EstateProvider>(context, listen: false)
          .filtersPriceType(_currentCurrencyId as int);
    }
  }

  _clearFilters() {
    Provider.of<EstateProvider>(context, listen: false).filtersClear();
  }

  _listenControllers() {
    _minPriceController.addListener(() {
      double? minValue = double.tryParse(_minPriceController.text);
      double? maxValue = double.tryParse(_maxPriceController.text);
      if (minValue != null && maxValue != null && minValue < maxValue) {
        setState(() {
          _selectedRange = RangeValues(minValue, _selectedRange.end);
        });
      }
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      await _fetchData();
      // _listenControllers();
      Map<String, dynamic> modalData =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      if (modalData.containsKey("onFilterCallback")) {
        onFilterCallback = modalData["onFilterCallback"];
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<FacilityModel> facilities =
        Provider.of<FacilityProvider>(context, listen: false).facilities;
    List<CurrencyModel> currencies =
        Provider.of<CurrencyProvider>(context, listen: false).currencies;

    if (currencies.length > 0) {
      Provider.of<EstateProvider>(context, listen: false)
          .filtersPriceType(currencies[0].id);
    }

    List checkedFacilities = Provider.of<EstateProvider>(context, listen: false)
        .filters["facilities"];

    int priceType = Provider.of<EstateProvider>(context, listen: false)
        .filters["priceType"];
    if (_currentCurrencyId == null && priceType != null) {
      _currentCurrencyId = priceType;
    }

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          _clearFilters();
          return true;
        },
        child: Scaffold(
          appBar: buildNavigationalAppBar(
              context, Locales.string(context, "filters"), () {
            _clearFilters();
          }, [
            IconButton(
              onPressed: () {
                _clearFilters();
                onFilterCallback!();
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.refresh_rounded),
              color: greyishLight,
            ),
          ]),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      defaultPadding,
                      defaultPadding,
                      defaultPadding,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Locales.string(context, "sort_by"),
                          style: TextStyles.display5(),
                        ),
                        _buildOrderFilers(_sortingTypes as List<String>,
                            _currentSort as String),
                        SizedBox(height: defaultPadding / 2),
                        Divider(height: 0),
                        SizedBox(height: defaultPadding),
                        Text(
                          Locales.string(context, "enter_address"),
                          style: TextStyles.display5(),
                        ),
                        SizedBox(height: 12),
                        TextInput(
                          hintText: Locales.string(context, "address"),
                          controller: _addressController,
                        ),
                        SizedBox(height: defaultPadding),
                        Text(
                          Locales.string(context, "choose_popular_place"),
                          style: TextStyles.display5(),
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 45,
                          margin: EdgeInsets.only(top: 10),
                          child: SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(),
                            child: FindDropdown<String>(
                              items:
                                  _places.map((place) => place.title).toList(),
                              label: Locales.string(context, "choose_one"),
                              labelVisible: false,
                              selectedItem: _currentPlace,
                              onChanged: (value) {
                                _currentPlace = value as String;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: defaultPadding),
                        Text(
                          Locales.string(context, "set_price"),
                          style: TextStyles.display5(),
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: 100.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 50.w - 1.375 * defaultPadding,
                                child: TextInput(
                                  controller: _minPriceController,
                                  hintText:
                                      _selectedRange.start.toStringAsFixed(1),
                                ),
                              ),
                              Container(
                                width: 50.w - 1.375 * defaultPadding,
                                child: TextInput(
                                  controller: _maxPriceController,
                                  hintText:
                                      _selectedRange.end.toStringAsFixed(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildRangeSlider(),
                        Row(
                          children: [
                            ...currencies.map((currency) {
                              bool isActive = _currentCurrencyId == null
                                  ? currencies.indexOf(currency) == 0
                                  : _currentCurrencyId == currency.id;
                              bool isFirst = currencies.indexOf(currency) == 0;
                              bool isLast = currencies.indexOf(currency) ==
                                  currencies.length - 1;

                              return Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    _changeCurrency(currency.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        isActive ? normalOrange : inputGrey,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    minimumSize: Size(0, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: isFirst
                                          ? BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                            )
                                          : (isLast
                                              ? BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  bottomRight:
                                                      Radius.circular(15),
                                                )
                                              : BorderRadius.zero),
                                    ),
                                  ),
                                  child: Text(
                                    currency.title,
                                    style: TextStyles.display1().copyWith(
                                      letterSpacing: 0.3,
                                      color:
                                          isActive ? inputGrey : greyishLight,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        SizedBox(height: defaultPadding / 2),
                        Divider(height: 0),
                        SizedBox(height: defaultPadding),
                        Text(
                          Locales.string(context, "extra_filters"),
                          style: TextStyles.display5(),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          children: [
                            ...facilities
                                .map(
                                  (facility) => CustomCheckbox(
                                    title: facility.title,
                                    value:
                                        checkedFacilities.contains(facility.id),
                                    onTap: () {
                                      setState(() {
                                        Provider.of<EstateProvider>(context,
                                                listen: false)
                                            .filtersToggleFacility(facility.id);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                        SizedBox(height: 5 * defaultPadding),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: Container(
            width: 100.w - 2 * defaultPadding,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                _setAllFilters();
                onFilterCallback!();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: normalOrange,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                Locales.string(context, "show_results"),
                style: TextStyles.display6(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSlider() {
    print(_priceConstraints);
    print(_priceConstraints);
    print(_selectedRange);
    return RangeSlider(
      min: _priceConstraints.start,
      max: _priceConstraints.end,
      divisions: _divisions,
      values: _selectedRange,
      onChanged: (RangeValues newRange) {
        _minPriceController.text = newRange.start.toStringAsFixed(1);
        _maxPriceController.text = newRange.end.toStringAsFixed(1);
        setState(() {
          _selectedRange = newRange;
        });
      },
      activeColor: normalOrange,
    );
  }

  Widget _buildOrderFilers(List<String> sortingTypes, String currentSort) {
    return Row(
      children: [
        ...sortingTypes
            .map(
              (sort) => SmallButton(
                Locales.string(context, sort),
                enabled: currentSort == sort,
                onPressed: () {
                  setState(() {
                    _currentSort = sort;
                  });
                },
              ),
            )
            .toList(),
      ],
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    Key? key,
    required this.title,
    required this.value,
    this.onTap,
    this.onChanged,
  }) : super(key: key);

  final String title;
  final bool value;
  final void Function()? onTap;
  final void Function(bool? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SizedBox(
          width: 44.w,
          height: 20,
          child: Row(
            children: [
              Theme(
                data: ThemeData(
                  unselectedWidgetColor: inputGrey,
                ),
                child: Checkbox(
                  onChanged: onChanged ??
                      (value) {
                        onTap!();
                      },
                  value: value,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: normalOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(title)
            ],
          ),
        ),
      ),
    );
  }
}
