import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/components/text_input.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/currency_model.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/facility_provider.dart';
import 'package:dachaturizm/styles/text_styles.dart';
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
  final RangeValues _sumConstraints = RangeValues(0, 999999);
  RangeValues? _selectedRange;
  bool _isInit = true;
  bool _isLoading = true;
  List? _sortingTypes;
  String? _currentSort;
  int? _currentCurrencyId;

  TextEditingController _addressController = TextEditingController();
  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();

  _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      Provider.of<FacilityProvider>(context, listen: false).getFacilities(),
      Provider.of<CurrencyProvider>(context, listen: false).getCurrencies(),
    ]);

    double minPrice =
        Provider.of<EstateProvider>(context, listen: false).filters["minPrice"];
    double maxPrice =
        Provider.of<EstateProvider>(context, listen: false).filters["maxPrice"];

    _minPriceController.text = minPrice.toString();
    if (maxPrice == 0.0) {
      _maxPriceController.text = "10000";
      _selectedRange = RangeValues(minPrice, 10000);
    } else {
      _maxPriceController.text = maxPrice.toString();
      _selectedRange = RangeValues(minPrice, maxPrice);
    }

    _sortingTypes = Provider.of<EstateProvider>(context, listen: false).sorting;
    _currentSort =
        Provider.of<EstateProvider>(context, listen: false).filters["sorting"];
    _addressController.text =
        Provider.of<EstateProvider>(context, listen: false).filters["address"];

    setState(() {
      _isLoading = false;
    });
  }

  _setAllFilters() {
    Provider.of<EstateProvider>(context, listen: false)
        .filtersAddress(_addressController.text);

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
          _selectedRange = RangeValues(minValue, _selectedRange!.end);
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
      _listenControllers();
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
          }),
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
                                      _selectedRange!.start.toStringAsFixed(1),
                                ),
                              ),
                              Container(
                                width: 50.w - 1.375 * defaultPadding,
                                child: TextInput(
                                  controller: _maxPriceController,
                                  hintText:
                                      _selectedRange!.end.toStringAsFixed(1),
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
                                  onPressed: () {
                                    setState(() {
                                      _currentCurrencyId = currency.id;
                                    });
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
    return RangeSlider(
      min: _sumConstraints.start,
      max: _sumConstraints.end,
      divisions: (_sumConstraints.end ~/ 5),
      values: _selectedRange as RangeValues,
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
