import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/currency_model.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/models/region_model.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/facility_provider.dart';
import 'package:dachaturizm/providers/region_provider.dart';
import 'package:dachaturizm/screens/styles/input.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SearchFilersScreen extends StatefulWidget {
  const SearchFilersScreen({Key? key}) : super(key: key);

  static String routeName = "/search-filters";

  @override
  _SearchFilersScreenState createState() => _SearchFilersScreenState();
}

class _SearchFilersScreenState extends State<SearchFilersScreen> {
  bool _isLoading = true;
  Map<int, bool> _checks = {};
  CurrencyModel _currentCurrency = CurrencyModel(id: 0, title: "UZS");
  int indexZero = 0;
  String _currentRegion = "";
  TextEditingController _fromPrice = TextEditingController();
  TextEditingController _toPrice = TextEditingController();
  GlobalKey _form = GlobalKey<FormState>();

  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero).then((_) {
      Provider.of<FacilityProvider>(context, listen: false)
          .fetchAndSetFacilities()
          .then((facilities) {
        for (int i = 0; i < facilities.length; i++) {
          _checks[i] = false;
        }
        Provider.of<CurrencyProvider>(context, listen: false)
            .fetchAndSetCurrencies()
            .then((_) {
          Provider.of<RegionProvider>(context, listen: false)
              .getAndSetRegions()
              .then((_) {
            setState(() {
              _isLoading = false;
            });
          });
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    _fetchAll();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<FacilityModel> facilities =
        Provider.of<FacilityProvider>(context, listen: false).facilities;
    List<CurrencyModel> currencies =
        Provider.of<CurrencyProvider>(context, listen: false).currencies;
    List<RegionModel> regions =
        Provider.of<RegionProvider>(context, listen: false).regions;

    Map<String, dynamic> filters =
        Provider.of<EstateProvider>(context, listen: false).searchFilters;

    if (filters["region"] != "") {
      _currentRegion =
          (regions.firstWhere((region) => region.title == filters["region"]).id)
              .toString();
    }

    print(filters);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Search Filters"),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                width: 100.w,
                padding: EdgeInsets.fromLTRB(
                  defaultPadding,
                  defaultPadding / 2,
                  defaultPadding,
                  0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text1("Regions"),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _currentRegion,
                        items: [
                          DropdownMenuItem<String>(
                            value: "",
                            child: Text("Viloyatni tanlang"),
                          ),
                          ...regions.map((region) {
                            return DropdownMenuItem<String>(
                              value: region.id.toString(),
                              child: Text(region.title),
                            );
                          }).toList()
                        ],
                        onChanged: (value) {
                          setState(() {
                            _currentRegion = value as String;
                          });
                          RegionModel region = RegionModel(id: 0, title: "");
                          for (int i = 0; i < regions.length; i++) {
                            if (regions[i].id == int.parse(value as String)) {
                              region = regions[i];
                            }
                          }
                          Provider.of<EstateProvider>(context, listen: false)
                              .setRegionFilter(region.title);
                        },
                      ),
                      SizedBox(
                        height: defaultPadding,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text1("Price range"),
                          _buildCurrenciesRow(currencies),
                        ],
                      ),
                      Form(
                        key: _form,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PriceInput(
                              hintText: "from",
                              controller: _fromPrice,
                            ),
                            PriceInput(
                              hintText: "to",
                              controller: _toPrice,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: defaultPadding,
                      ),
                      Text1("Facilities"),
                      _buildFacilityList(facilities),
                    ],
                  ),
                ),
              ),
        floatingActionButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: normalOrange,
            minimumSize: Size(100.w - 2 * defaultPadding, 50),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            "Show results",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  Row _buildCurrenciesRow(List<CurrencyModel> currencies) {
    return Row(
      children: [
        ...currencies.map((currency) {
          int index = currencies.indexOf(currency);
          return SmallButton(
            currency.title,
            enabled: index == indexZero || _currentCurrency == currency,
            onPressed: () {
              Provider.of<EstateProvider>(context, listen: false)
                  .setPriceType(currency.id);
              setState(() {
                _currentCurrency = currency;
                indexZero = -1;
              });
            },
          );
        }).toList()
      ],
    );
  }

  Widget _buildFacilityList(List<FacilityModel> facilities) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: [
        ...facilities.map((facility) {
          int index = facilities.indexOf(facility);
          return Container(
            width: 170,
            child: CheckboxListTile(
              value: _checks[index],
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.all(0),
              dense: false,
              activeColor: normalOrange,
              selectedTileColor: lightPurple,
              onChanged: (change) {
                setState(() {
                  _checks[index] = change as bool;
                });
              },
              title: Text(
                facilities[index].title,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList()
      ],
    );
  }

  @override
  void dispose() {
    print(_fromPrice);
    print(_toPrice);
    // Provider.of<EstateProvider>(context, listen: false).setFromPriceFilter(value);
    _fromPrice.dispose();
    _toPrice.dispose();
    super.dispose();
  }
}

class PriceInput extends StatelessWidget {
  const PriceInput({
    Key? key,
    this.hintText = "",
    required this.controller,
  }) : super(key: key);

  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 48.w - defaultPadding,
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          border: InputStyles.inputBorder(),
          focusedBorder: InputStyles.focusBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: defaultPadding / 2,
            vertical: defaultPadding / 2,
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
