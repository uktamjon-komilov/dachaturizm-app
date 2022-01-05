import 'dart:io';

import 'package:dachaturizm/components/booked_days_hint.dart';
import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/normal_input.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/booking_day.dart';
import 'package:dachaturizm/models/currency_model.dart';
import 'package:dachaturizm/models/district_model.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/models/region_model.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/facility_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/providers/category_provider.dart';
import 'package:dachaturizm/screens/app/estate/location_picker_screen.dart';
import 'package:dachaturizm/screens/app/estate/plans_screen.dart';
import 'package:dachaturizm/screens/app/search/filters_screen.dart';
import 'package:dachaturizm/screens/app/user/my_announcements_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:find_dropdown/find_dropdown.dart';

class EstateCreationPageScreen extends StatefulWidget {
  const EstateCreationPageScreen({Key? key}) : super(key: key);

  static String routeName = "/estate-edit";

  @override
  _EstateCreationPageScreenState createState() =>
      _EstateCreationPageScreenState();
}

class _EstateCreationPageScreenState extends State<EstateCreationPageScreen> {
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isSubmitted = false;
  bool _isEditing = false;
  int _currentExtraImageIndex = 0;
  int _descriptionMaxLength = 1000;
  EstateModel? _estate;
  List<RegionModel> _regions = [];
  List<DistrictModel> _districts = [];
  List<CategoryModel> _categories = [];
  String errors = "";
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController();

  FocusNode _titleFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _announcerFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _addressFocusNode = FocusNode();
  FocusNode _weekdayPriceFocusNode = FocusNode();
  FocusNode _weekendPriceFocusNode = FocusNode();

  dynamic? _mainImage;
  List _extraImages = List.generate(8, (_) => null);
  String _currentSection = "0";
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _announcerController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _weekdayPriceController = TextEditingController();
  TextEditingController _weekendPriceController = TextEditingController();
  int _currentCurrencyId = 0;
  String _currentRegion = "0";
  String _currentDistrict = "0";
  List<int> _facilities = [];
  double _longtitude = 0.0;
  double _latitute = 0.0;
  String _locationName = "";

  void _resetInputs() {
    _mainImage = null;
    _extraImages = List.generate(8, (_) => null);
    _currentSection = "0";
    _titleController.text = "";
    _descriptionController.text = "";
    _announcerController.text = "";
    _phoneController.text = "";
    _addressController.text = "";
    _weekdayPriceController.text = "";
    _weekendPriceController.text = "";
    _currentCurrencyId = 0;
    _currentRegion = "0";
    _currentDistrict = "0";
    _facilities = [];
    _longtitude = 0.0;
    _latitute = 0.0;
    _locationName = "";
  }

  List<String> get _bookedDays {
    return _selectedDays.map((day) => day.date).toList();
  }

  beforeSending() {
    if (!_form.currentState!.validate() ||
        _mainImage == null ||
        _currentSection == 0 ||
        _currentCurrencyId == "0" ||
        _currentRegion == "0" ||
        _currentDistrict == "0") {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.bounceIn,
      );
      setState(() {
        _isSubmitted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(Locales.string(context, "there_is_error_in_filling_in")),
        ),
      );
      return {"status": false};
    }
    print(1);
    Map<String, dynamic> data = {};
    data["photo"] = _mainImage;
    data["photos"] = _extraImages.where((image) => image != null).toList();
    data["estate_type"] = _categories
        .firstWhere((element) => element.title == _currentSection.toString())
        .id;
    data["title"] = _titleController.text;
    data["region"] = _regions
        .firstWhere((region) => region.title.toString() == _currentRegion);
    data["district"] = _districts.firstWhere(
        (district) => district.title.toString() == _currentDistrict);
    data["address"] = _addressController.text;
    data["longtitute"] = _longtitude;
    data["latitute"] = _latitute;
    data["description"] = _descriptionController.text;
    print(2);
    data["booked_days"] = _bookedDays;
    data["facilities"] = _facilities;
    data["announcer"] = _announcerController.text;
    data["phone"] = _phoneController.text;
    data["weekday_price"] = _weekdayPriceController.text;
    data["weekend_price"] = _weekendPriceController.text;
    data["price_type"] = _currentCurrencyId.toString();

    data["beds"] = "0";
    data["pool"] = "0";
    data["people"] = "0";
    data["is_published"] = "true";
    print(3);
    return data;
  }

  sendData() {
    Map<String, dynamic> data = beforeSending();
    _resetInputs();
    if (data.containsKey("status")) return;
    return data;
  }

  Future<dynamic> updateData() async {
    Map<String, dynamic> data = beforeSending();
    if (data.containsKey("status")) return;
    setState(() {
      _isUploading = true;
      _isSubmitted = false;
    });
    final userId =
        await Provider.of<AuthProvider>(context, listen: false).getUserId();
    Provider.of<EstateProvider>(context, listen: false)
        .updateEstate(userId, data, _estate)
        .then((value) async {
      print(value);
      _resetInputs();
      setState(() {
        _isUploading = false;
      });
      Provider.of<NavigationScreenProvider>(context, listen: false)
          .changePageIndex(5);
      await callWithAuth(context, () async {
        Navigator.of(context).pushNamed(MyAnnouncements.routeName);
      });
      return value;
    });
  }

  final Set<BookingDay> _selectedDays = Set<BookingDay>();
  DateTime now = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    BookingDay tempSelectedDay = BookingDay.toObj(selectedDay);

    setState(() {
      try {
        _focusedDay = focusedDay;
      } catch (error) {}
      if (_selectedDays.contains(tempSelectedDay)) {
        _selectedDays
            .removeWhere((element) => element.date == tempSelectedDay.date);
      } else {
        _selectedDays.add(tempSelectedDay);
      }
    });
  }

  Future<dynamic> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    return imageFile == null ? null : imageFile.path;
  }

  Future<void> _selectMainImage() async {
    final image = await _selectImage();
    if (image == null) {
      setState(() {
        _mainImage = null;
      });
      return;
    }

    setState(() {
      _mainImage = File(image as String);
    });
  }

  Future<void> _selectExtraImage(index) async {
    final image = await _selectImage();
    if (image == null) {
      setState(() {
        _extraImages[index] = null;
        if (index > 0 && _extraImages[index + 1] != null)
          _currentExtraImageIndex = index - 1;
      });
    } else {
      setState(() {
        _extraImages[index] = File(image as String);
        _currentExtraImageIndex = index + 1;
      });
    }
  }

  Widget _buildMainImagePicker({
    dynamic? photo,
    Function? callback,
    double? width,
    double? height,
    bool disabled = true,
    double iconScale = 1,
  }) {
    if (height == null) height = 40.w;
    if (width == null) width = height;

    return GestureDetector(
      onTap: () {
        if (disabled)
          return;
        else if (callback != null) {
          callback();
        }
      },
      child: Container(
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: disabled ? lightGrey : lessNormalGrey,
            ),
            child: photo == null
                ? Center(
                    child: Image.asset(
                      "assets/images/fi-rr-camera.png",
                      scale: iconScale,
                    ),
                  )
                : _isEditing
                    ? Image.network(
                        fixMediaUrl(photo),
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        photo as File,
                        fit: BoxFit.cover,
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtraImagesGrid() {
    return Wrap(
      spacing: 0.5 * defaultPadding,
      runSpacing: 0.5 * defaultPadding,
      children: [
        ...List.generate(
          8,
          (index) => _buildMainImagePicker(
            width: (100.w - 3.5 * defaultPadding) / 4,
            height: (100.w - 3.5 * defaultPadding) / 4,
            photo: _extraImages[index],
            callback: () => _selectExtraImage(index),
            disabled: index > _currentExtraImageIndex,
            iconScale: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionRow(List<String> values, value, String placeHolder,
      {void Function(String?)? onChanged}) {
    return Container(
      height: 45,
      margin: EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: FindDropdown<String>(
          items: values,
          label: "Choose one",
          labelVisible: false,
          selectedItem: "",
          onChanged: onChanged ??
              (value) {
                print(value);
              },
          validate: (String? item) {
            if (item == null)
              return "Required field";
            else if (!value.contains(item))
              return "Invalid item";
            else
              return null;
          },
        ),
      ),
    );
    // return Container(
    //   child: DropdownButton(
    //     borderRadius: BorderRadius.circular(10),
    //     elevation: 1,
    //     isExpanded: true,
    //     value: value,
    //     menuMaxHeight: 40.h,
    //     items: [
    //       DropdownMenuItem(
    //         value: 0,
    //         child: Text(placeHolder),
    //       ),
    //       ...values.map((value) {
    //         return DropdownMenuItem(
    //           value: value.id,
    //           child: Text(value.title),
    //         );
    //       }).toList()
    //     ],
    //     onChanged: (value) {
    //       if (onChanged != null) {
    //         onChanged(value);
    //       }
    //     },
    //   ),
    // );
  }

  _showGoogleMap(BuildContext context) async {
    final data = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => LocationPickerScreen()));
    setState(() {
      _longtitude = data["position"].longitude;
      _latitute = data["position"].latitude;
      if (data["street"] != "" &&
          data["subAdministrativeArea"] != "" &&
          data["administrativeArea"] != "" &&
          data["country"] != "") {
        _locationName = data["street"] +
            ", " +
            data["subAdministrativeArea"] +
            ", " +
            data["administrativeArea"] +
            ", " +
            data["country"];
        _addressController.text = _locationName;
      } else {
        _locationName = "";
        _addressController.text = "";
      }
    });
  }

  Widget _buildLocationPicker() {
    return GestureDetector(
      onTap: () async {
        _showGoogleMap(context);
      },
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                width: 100.w,
                height: 150,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                  child: Image.asset(
                    "assets/images/default_map_placeholder.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _locationName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Text(
                        _locationName == ""
                            ? Locales.string(context, "tap_to_choose_location")
                            : Locales.string(context, "tap_to_change_location"),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildFacilitiesGrid(List<FacilityModel> facilities) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: [
        ...facilities.map((facility) {
          int index = facilities.indexOf(facility);
          return CustomCheckbox(
            value: _facilities.contains(facility.id),
            title: facilities[index].title,
            onTap: () {
              setState(() {
                if (_facilities.contains(facility.id)) {
                  _facilities.remove(facility.id);
                } else {
                  _facilities.add(facility.id);
                }
              });
            },
          );
        }).toList()
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: now,
      lastDay: DateTime.utc(now.year + 1, 12, 31),
      focusedDay: _focusedDay,
      locale: Locales.currentLocale(context).toString(),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: darkPurple,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleTextFormatter: (date, locale) =>
            "${DateFormat.y(locale).format(date)}, ${DateFormat.MMMM(locale).format(date)}",
      ),
      calendarStyle: CalendarStyle(
        cellMargin: EdgeInsets.all(3),
        selectedDecoration: BoxDecoration(
          color: normalOrange,
          borderRadius: BorderRadius.circular(5),
        ),
        defaultDecoration:
            BoxDecoration(borderRadius: BorderRadius.circular(5)),
        todayDecoration: BoxDecoration(
          color: lightPurple,
          borderRadius: BorderRadius.circular(5),
        ),
        todayTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      selectedDayPredicate: (day) {
        return _selectedDays.contains(BookingDay.toObj(day));
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: _onDaySelected,
    );
  }

  Widget _buildPriceTypeRow(List<CurrencyModel> currencies) {
    return Row(
      children: [
        ...currencies.map((currency) {
          return Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentCurrencyId = currency.id;
                });
              },
              style: ElevatedButton.styleFrom(
                primary: currency.id == _currentCurrencyId
                    ? normalOrange
                    : Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                currency.title,
                style: TextStyle(
                  color: currency.id == _currentCurrencyId
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          );
        }).toList()
      ],
    );
  }

  @override
  void didChangeDependencies() {
    _descriptionController.addListener(() {
      setState(() {});
    });
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero).then((_) async {
      Future.wait([
        Provider.of<FacilityProvider>(context, listen: false)
            .getAddresses()
            .then((value) {
          setState(() {
            _regions = value;
          });
        }),
        Provider.of<FacilityProvider>(context, listen: false).getFacilities(),
        Provider.of<CurrencyProvider>(context, listen: false).getCurrencies(),
        Provider.of<EstateTypesProvider>(context, listen: false)
            .getCategories()
            .then((value) => _categories = value),
        Provider.of<AuthProvider>(context, listen: false)
            .getUserData()
            .then((user) {
          if (user.runtimeType.toString() == "UserModel") {
            _announcerController.text = "${user!.firstName} ${user.lastName}";
            _phoneController.text = "+${user.phone}";
          }
        }),
      ]).then((_) async {
        Map data = ModalRoute.of(context)?.settings.arguments as Map;
        String locale = await getCurrentLocale();
        if (data == null) return;
        if (data.containsKey("estate")) {
          setState(() {
            _isEditing = true;
          });
          Provider.of<EstateProvider>(context, listen: false)
              .getEstateById(data["estate"])
              .then((value) {
            _estate = value;
            _mainImage = value.photo;
            print(_mainImage);
            _extraImages = List.generate(8, (_) => null);
            value.photos.forEach((photo) {
              int index = value.photos.indexOf(photo);
              _extraImages[index] = photo.photo;
            });
            _currentSection = value.typeId.toString();
            _titleController.text = value.title;
            _descriptionController.text = value.description;
            _announcerController.text = value.announcer;
            _phoneController.text = value.phone;
            _addressController.text = value.address;
            _weekdayPriceController.text = value.weekdayPrice.toString();
            _weekendPriceController.text = value.weekendPrice.toString();
            _currentCurrencyId = int.parse(value.priceType);
            // _currentRegion = _regions.firstWhere((region) => region.translations[]);
            // _currentDistrict = 0;
            _facilities =
                value.facilities.map((facility) => facility.id).toList();
            _longtitude = value.longtitute;
            _latitute = value.latitute;
          });
        }
      });
    });
    setState(() {
      _isLoading = false;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _announcerController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _weekdayPriceController.dispose();
    _weekendPriceController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _announcerFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _weekdayPriceFocusNode.dispose();
    _weekendPriceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<FacilityModel> facilities =
        Provider.of<FacilityProvider>(context, listen: false).facilities;
    List<CategoryModel> categories =
        Provider.of<EstateTypesProvider>(context, listen: false).categories;
    List<CurrencyModel> currencies =
        Provider.of<CurrencyProvider>(context, listen: false).currencies;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _isUploading
              ? Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Locales.string(context, "saving"),
                        style: TextStyle(
                          color: normalOrange,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: defaultPadding,
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: normalOrange,
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  padding: EdgeInsets.fromLTRB(
                    defaultPadding,
                    0,
                    defaultPadding,
                    0,
                  ),
                  child: Form(
                    key: _form,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: defaultPadding),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 40.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Locales.string(context, "main_photo"),
                                      style: TextStyles.display9(),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      Locales.string(
                                          context, "this_photo_is_main"),
                                      style: TextStyles.display10(),
                                    ),
                                  ],
                                ),
                              ),
                              _buildMainImagePicker(
                                photo: _mainImage,
                                callback: _selectMainImage,
                                disabled: false,
                                height: 45.w,
                              ),
                            ],
                          ),
                          ErrorText(
                            errorText: Locales.string(context, "pick_a_photo"),
                            display: (_isSubmitted && _mainImage == null),
                          ),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "gallary"),
                            style: TextStyles.display9(),
                          ),
                          VerticalHorizontalSizedBox(),
                          _buildExtraImagesGrid(),
                          VerticalHorizontalHalfSizedBox(),
                          Text(
                            Locales.string(context, "max_photo_count_8"),
                            style: TextStyles.display10(),
                          ),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "choose_section"),
                            style: TextStyles.display9(),
                          ),
                          _buildSelectionRow(
                              categories
                                  .map((category) => category.title)
                                  .toList(),
                              _currentSection,
                              Locales.string(context, "choose_section"),
                              onChanged: (value) {
                            setState(() {
                              _currentSection = value as String;
                            });
                          }),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "region"),
                            style: TextStyles.display9(),
                          ),
                          _buildSelectionRow(
                              _regions.map((region) => region.title).toList(),
                              _currentRegion,
                              Locales.string(context, "choose_region"),
                              onChanged: (value) {
                            setState(() {
                              _currentRegion = value as String;
                              if (_currentRegion == "0") {
                                setState(() {
                                  _currentDistrict = "0";
                                  _districts = [];
                                });
                              } else {
                                setState(() {
                                  _districts = _regions
                                      .firstWhere((region) =>
                                          region.title.toString() ==
                                          _currentRegion)
                                      .districts;
                                });
                              }
                            });
                          }),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "district"),
                            style: TextStyles.display9(),
                          ),
                          _buildSelectionRow(
                              _districts
                                  .map((district) => district.title)
                                  .toList(),
                              _currentDistrict,
                              Locales.string(context, "choose_district"),
                              onChanged: (value) {
                            setState(() {
                              _currentDistrict = value as String;
                            });
                          }),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "choose_title"),
                            style: TextStyles.display9(),
                          ),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: Locales.string(context, "example_title"),
                            controller: _titleController,
                            focusNode: _titleFocusNode,
                            onChanged: () {
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_addressFocusNode);
                            },
                          ),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "choose_location"),
                            style: TextStyles.display9(),
                          ),
                          VerticalHorizontalHalfSizedBox(),
                          _buildLocationPicker(),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "enter_address"),
                            style: TextStyles.display9(),
                          ),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText:
                                Locales.string(context, "example_address"),
                            controller: _addressController,
                            focusNode: _addressFocusNode,
                            onChanged: () {
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_descriptionFocusNode);
                            },
                          ),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "about_estate"),
                            style: TextStyles.display9(),
                          ),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: Locales.string(context, "about_estate"),
                            maxLines: 8,
                            maxLength: _descriptionMaxLength,
                            controller: _descriptionController,
                            focusNode: _descriptionFocusNode,
                            onChanged: () {
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_announcerFocusNode);
                            },
                          ),
                          VerticalHorizontalHalfSizedBox(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  Locales.string(context, "at_least_50_chars")),
                              Text(
                                  "${_descriptionController.text.length}/${_descriptionMaxLength}"),
                            ],
                          ),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "booked_days_if_any"),
                            style: TextStyles.display9(),
                          ),
                          _buildCalendar(),
                          VerticalHorizontalHalfSizedBox(),
                          BookedDaysHint(),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "adding_filters"),
                            style: TextStyles.display9(),
                          ),
                          VerticalHorizontalHalfSizedBox(),
                          _buildFacilitiesGrid(facilities),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "contact"),
                            style: TextStyles.display9(),
                          ),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: Locales.string(context, "fullname"),
                            controller: _announcerController,
                            focusNode: _announcerFocusNode,
                            validation: false,
                            onChanged: () {
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_phoneFocusNode);
                            },
                          ),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: Locales.string(context, "phone"),
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            isPhone: true,
                            onChanged: () {
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_weekdayPriceFocusNode);
                            },
                          ),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "price"),
                            style: TextStyles.display9(),
                          ),
                          VerticalHorizontalHalfSizedBox(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 43.w,
                                child: NormalTextInput(
                                  hintText:
                                      Locales.string(context, "weekday_price"),
                                  controller: _weekdayPriceController,
                                  focusNode: _weekdayPriceFocusNode,
                                  isPrice: true,
                                  onChanged: () {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  onSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(_weekendPriceFocusNode);
                                  },
                                ),
                              ),
                              Container(
                                width: 43.w,
                                child: NormalTextInput(
                                  hintText:
                                      Locales.string(context, "weekend_price"),
                                  controller: _weekendPriceController,
                                  focusNode: _weekendPriceFocusNode,
                                  isPrice: true,
                                  onChanged: () {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                  onSubmitted: (value) {},
                                ),
                              ),
                            ],
                          ),
                          _buildPriceTypeRow(currencies),
                          ErrorText(
                            errorText:
                                Locales.string(context, "choose_currency"),
                            display: (_isSubmitted && _currentCurrencyId == 0),
                          ),
                          VerticalHorizontalSizedBox(),
                          FluidBigButton(
                            onPress: () async {
                              if (_isEditing) {
                                await updateData();
                              } else {
                                dynamic data = await sendData();
                                Navigator.of(context).pushNamed(
                                    PlansScreen.routeName,
                                    arguments: {"data": data});
                              }
                            },
                            text: _isEditing
                                ? Locales.string(context, "edit_estate")
                                : Locales.string(context, "save_estate"),
                          ),
                          VerticalHorizontalSizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

class ErrorText extends StatelessWidget {
  const ErrorText({
    Key? key,
    required this.errorText,
    this.display = false,
  }) : super(key: key);

  final String errorText;
  final bool display;

  @override
  Widget build(BuildContext context) {
    return display
        ? Text(
            errorText,
            style: TextStyle(
              color: Colors.red,
            ),
          )
        : Container();
  }
}

class VerticalHorizontalHalfSizedBox extends StatelessWidget {
  const VerticalHorizontalHalfSizedBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: defaultPadding / 2);
  }
}

class VerticalHorizontalSizedBox extends StatelessWidget {
  const VerticalHorizontalSizedBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: defaultPadding);
  }
}
