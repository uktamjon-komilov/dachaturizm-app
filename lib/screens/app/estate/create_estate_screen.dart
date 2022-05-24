import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/booked_days_hint.dart';
import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/normal_input.dart';
import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/booking_day.dart';
import 'package:dachaturizm/models/currency_model.dart';
import 'package:dachaturizm/models/district_model.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/models/popular_place_model.dart';
import 'package:dachaturizm/models/region_model.dart';
import 'package:dachaturizm/models/category_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/create_estate_provider.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/facility_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/providers/category_provider.dart';
import 'package:dachaturizm/screens/app/estate/location_picker_screen.dart';
import 'package:dachaturizm/screens/app/estate/plans_screen.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/app/search/filters_screen.dart';
import 'package:dachaturizm/screens/app/user/my_announcements_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:dio/dio.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:flutter_spinbox/cupertino.dart';
import 'package:dropdown_search/dropdown_search.dart';

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
  bool _mainImageUploading = false;
  List<bool> _extraImagesLoading = List.generate(8, (index) => false);
  bool _isSubmitted = false;
  bool _isEditing = false;
  bool _filtersOpen = false;
  int _currentExtraImageIndex = 0;
  int _descriptionMaxLength = 1000;
  EstateModel? _estate;
  int _estateId = 0;
  List<DistrictModel> _districts = [];
  List<CurrencyModel> _currencies = [];
  String errors = "";
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController();

  Set<BookingDay> _selectedDays = Set<BookingDay>();
  DateTime now = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  FocusNode _titleFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _announcerFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _addressFocusNode = FocusNode();
  FocusNode _weekdayPriceFocusNode = FocusNode();
  FocusNode _weekendPriceFocusNode = FocusNode();

  dynamic? _mainImage;
  int _mainImageId = 0;
  List _extraImages = List.generate(8, (_) => null);
  List _extraImagesId = List.generate(8, (_) => 0);
  List<Asset> images = <Asset>[];
  String _currentSection = "";
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _announcerController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _weekdayPriceController = TextEditingController();
  TextEditingController _weekendPriceController = TextEditingController();
  int _currentCurrencyId = 0;
  String? _currentRegion;
  String? _currentDistrict;
  String _currentPopularPlace = "";
  List<int> _facilities = [];
  double _longtitude = 0.0;
  double _latitute = 0.0;
  int _people = 1;
  int _beds = 1;
  int _pools = 1;
  String _locationName = "";

  void _resetInputs() {
    setState(() {
      _mainImage = null;
      _extraImages = List.generate(8, (_) => null);
      images = <Asset>[];
      _currentSection = "";
      _titleController.text = "";
      _descriptionController.text = "";
      _announcerController.text = "";
      _phoneController.text = "";
      _addressController.text = "";
      _weekdayPriceController.text = "";
      _weekendPriceController.text = "";
      _people = 1;
      _beds = 1;
      _pools = 1;
      _currentCurrencyId = 0;
      _currentRegion = null;
      _currentDistrict = null;
      _currentPopularPlace = "";
      _selectedDays = Set<BookingDay>();
      now = DateTime.now();
      _focusedDay = DateTime.now();
      _facilities = [];
      _longtitude = 0.0;
      _latitute = 0.0;
      _locationName = "";
    });
  }

  List<String> get _bookedDays {
    return _selectedDays.map((day) => day.date).toList();
  }

  beforeSending(context) {
    if (!_form.currentState!.validate() ||
        _mainImage == null ||
        _currentSection == "0" ||
        _currentCurrencyId == 0 ||
        _currentRegion == null ||
        _currentDistrict == null) {
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
    Map<String, dynamic> data = {};
    data["photo"] = _mainImageId;
    data["photos"] = _extraImagesId;
    data["estate_type"] = Provider.of<EstateTypesProvider>(context,
            listen: false)
        .categories
        .firstWhere((element) => element.title == _currentSection.toString())
        .id;
    data["title"] = _titleController.text;
    data["region"] = Provider.of<FacilityProvider>(context, listen: false)
        .regions
        .firstWhere((region) => region.title == _currentRegion);
    data["district"] =
        _districts.firstWhere((district) => district.title == _currentDistrict);
    data["popular_place_id"] =
        Provider.of<FacilityProvider>(context, listen: false).places.firstWhere(
            (place) => place.title.toString() == _currentPopularPlace,
            orElse: () {
      return PopularPlaceModel(id: 0, title: "");
    }).id;
    data["address"] = _addressController.text;
    data["longtitute"] = _longtitude;
    data["latitute"] = _latitute;
    data["description"] = _descriptionController.text;
    data["booked_days"] = _bookedDays;
    data["facilities"] = _facilities;
    data["announcer"] = _announcerController.text;
    data["phone"] = _phoneController.text;
    data["weekday_price"] = _weekdayPriceController.text;
    data["weekend_price"] = _weekendPriceController.text;
    data["price_type"] = _currentCurrencyId.toString();

    data["beds"] = _beds.toString();
    data["pool"] = _pools.toString();
    data["people"] = _people.toString();
    data["is_published"] = "true";
    print(data["photos"]);
    return data;
  }

  sendData(context) {
    Map<String, dynamic> data = beforeSending(context);
    if (data.containsKey("status")) return;
    _resetInputs();
    return data;
  }

  Future<dynamic> updateData(context) async {
    Map<String, dynamic> data = beforeSending(context);
    if (data.containsKey("status")) return;
    setState(() {
      _isUploading = true;
      _isSubmitted = false;
    });
    Provider.of<CreateEstateProvider>(context, listen: false)
        .updateEstate(_estateId, data, _estate)
        .then((value) async {
      _resetInputs();
      setState(() {
        _isUploading = false;
      });
      Provider.of<NavigationScreenProvider>(context, listen: false)
          .changePageIndex(4);
      await callWithAuth(context, () async {
        Navigator.of(context)
          ..popUntil(ModalRoute.withName(NavigationalAppScreen.routeName))
          ..pushNamed(MyAnnouncements.routeName);
      });
      return value;
    });
  }

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
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
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

    var photo = await MultipartFile.fromFile(_mainImage.path,
        filename: "testimage.png");

    setState(() {
      _mainImageUploading = true;
    });
    Provider.of<CreateEstateProvider>(context, listen: false)
        .uploadTempPhoto(photo)
        .then((value) {
      setState(() {
        _mainImageUploading = false;
      });
      _mainImageId = value;
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 8,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "OK",
        ),
        materialOptions: MaterialOptions(
          statusBarColor: "#F17C31",
          actionBarColor: "#F17C31",
          actionBarTitle: "DachaTurizm",
          allViewTitle: Locales.string(context, "all_photos"),
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {}

    if (!mounted) return;

    setState(() {
      images = resultList;
    });

    for (int i = 0; i < images.length; i++) {
      Asset image = images[i];

      ByteData byteData = await image.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      MultipartFile photo = MultipartFile.fromBytes(
        imageData,
        filename: "image.jpg",
        contentType: MediaType("image", "jpg"),
      );

      print(_currentExtraImageIndex);
      int index = i + _currentExtraImageIndex;
      print(_extraImagesId);
      print(index);
      print("----------------");

      while (index < 8 && _extraImagesId[index] != 0) {
        index += 1;
        if (index >= 8) break;
      }

      if (index >= 8) return;

      setState(() {
        _extraImagesLoading[index] = true;
      });

      int value =
          await Provider.of<CreateEstateProvider>(context, listen: false)
              .uploadExtraPhoto(photo);

      _extraImagesId[index] = value;

      String? name = await Provider.of<EstateProvider>(context, listen: false)
          .getExtraPhoto(value);

      _extraImages[index] = name;

      setState(() {
        _extraImagesLoading[index] = false;
      });
    }

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _descriptionController.addListener(() {
      setState(() {});
    });
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      Provider.of<AuthProvider>(context, listen: false)
          .getUserDataWithoutNotifying()
          .then((user) {
        if (user.runtimeType.toString() == "UserModel") {
          try {
            _announcerController.text = "${user!.firstName} ${user.lastName}";
          } catch (e) {}
          try {
            _phoneController.text = "+${user!.phone}";
          } catch (e) {}
        }

        Map? data;
        try {
          data = ModalRoute.of(context)?.settings.arguments as Map?;
        } catch (e) {
          data = null;
        }

        if (data == null) return;
        if (data.containsKey("estateId") && _estateId == 0) {
          _estateId = int.parse(data["estateId"]);
          setState(() {
            _isEditing = true;
          });
          Provider.of<EstateProvider>(context, listen: false)
              .getEstateById(int.parse(data["estateId"]))
              .then((value) {
            _estate = value;
            _mainImage = value.photo;
            _mainImageId = 0;
            _extraImages = List.generate(8, (_) => null);
            value.photos.forEach((photo) {
              int index = value.photos.indexOf(photo);
              _extraImages[index] = photo.photo;
              _extraImagesId[index] = photo.id;
            });
            _currentExtraImageIndex = value.photos.length;
            _titleController.text = value.title;
            _descriptionController.text = value.description;
            _announcerController.text = value.announcer;
            _phoneController.text = value.phone;
            _addressController.text = value.address;
            _weekdayPriceController.text = value.weekdayPrice.toString();
            _weekendPriceController.text = value.weekendPrice.toString();
            _currencies = Provider.of<CurrencyProvider>(context, listen: false)
                .currencies;
            _currentCurrencyId = _currencies
                .firstWhere((currency) => currency.title == value.priceType)
                .id;
            _currentSection =
                Provider.of<EstateTypesProvider>(context, listen: false)
                    .categories
                    .firstWhere((category) => category.id == value.typeId,
                        orElse: () {
                      return CategoryModel(
                        id: 0,
                        title: "",
                        slug: "",
                        icon: "",
                        foregroundColor: "",
                        backgroundColor: "",
                      );
                    })
                    .title
                    .toString();
            List<RegionModel> tempRegions =
                Provider.of<FacilityProvider>(context, listen: false).regions;
            _currentRegion = tempRegions
                .firstWhere((region) => region.title == value.region,
                    orElse: () {
                  return RegionModel(
                      id: 0, title: "", translations: {}, districts: []);
                })
                .title
                .toString();
            _districts = tempRegions.firstWhere(
                (region) => region.title == _currentRegion, orElse: () {
              return RegionModel(
                  id: 0, title: "", districts: [], translations: {});
            }).districts;
            _currentDistrict = _districts
                .firstWhere((district) => district.title == value.district,
                    orElse: () {
                  return DistrictModel(
                    id: 0,
                    title: "",
                    translations: {},
                  );
                })
                .title
                .toString();
            _facilities =
                value.facilities.map((facility) => facility.id).toList();
            _longtitude = value.longtitute;
            _latitute = value.latitute;
            _selectedDays = value.bookedDays.toSet();
            _people = value.people;
            _beds = value.beds;
            _pools = value.pool;
          });
        }
      }).then((_) {
        try {
          setState(() {
            _isLoading = false;
          });
        } catch (e) {}
      });
    });
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
      appBar: _isEditing
          ? buildNavigationalAppBar(
              context,
              Locales.string(context, "estate_editing_title"),
            )
          : null,
      body: _isLoading
          ? Center(
              child: const CircularProgressIndicator(),
            )
          : _isUploading
              ? Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Locales.string(context, "saving"),
                        style: const TextStyle(
                          color: normalOrange,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Container(
                        width: 20,
                        height: 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: normalOrange,
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.fromLTRB(
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
                          const SizedBox(height: defaultPadding),
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
                                    const SizedBox(height: 12),
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
                                uploading: _mainImageUploading,
                              ),
                            ],
                          ),
                          ErrorText(
                            errorText: Locales.string(context, "pick_a_photo"),
                            display: (_isSubmitted && _mainImage == null),
                          ),
                          const VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "gallary"),
                            style: TextStyles.display9(),
                          ),
                          const VerticalHorizontalSizedBox(),
                          _buildExtraImagesGrid(),
                          const VerticalHorizontalHalfSizedBox(),
                          Text(
                            Locales.string(context, "max_photo_count_8"),
                            style: TextStyles.display10(),
                          ),
                          const VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "choose_section"),
                            style: TextStyles.display9(),
                          ),
                          Row(
                            children: [
                              ...categories.map((category) {
                                return SmallButton(category.title,
                                    enabled: _currentSection == category.title,
                                    onPressed: () {
                                  setState(() {
                                    _currentSection = category.title;
                                    _facilities = [];
                                  });
                                  Provider.of<FacilityProvider>(context,
                                          listen: false)
                                      .getFacilities(category.id.toString())
                                      .then((_) {
                                    setState(() {});
                                  });
                                });
                              }).toList()
                            ],
                          ),
                          const VerticalHorizontalSizedBox(),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _filtersOpen = !_filtersOpen;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              side: BorderSide(
                                color: disabledGrey,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              Locales.string(context, "adding_filters") +
                                  (_filtersOpen ? " ▼" : " ▲"),
                              style: TextStyles.display9(),
                            ),
                          ),
                          const VerticalHorizontalHalfSizedBox(),
                          _buildFacilitiesGrid(facilities),
                          const VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "region"),
                            style: TextStyles.display9(),
                          ),
                          _buildSelectionRow(
                              Provider.of<FacilityProvider>(context,
                                      listen: false)
                                  .regions
                                  .map((region) => region.title)
                                  .toList(),
                              _currentRegion,
                              Locales.string(context, "choose_region"),
                              onChanged: (value) {
                            _currentRegion = value as String;
                            if (_currentRegion == null) {
                              setState(() {
                                _districts = [];
                                _currentDistrict = null;
                              });
                            } else {
                              _districts = Provider.of<FacilityProvider>(
                                      context,
                                      listen: false)
                                  .regions
                                  .firstWhere((region) =>
                                      region.title == _currentRegion)
                                  .districts;
                              setState(() {
                                _currentDistrict = null;
                              });
                            }
                          }),
                          const VerticalHorizontalSizedBox(),
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
                          const VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "popular_place"),
                            style: TextStyles.display9(),
                          ),
                          _buildSelectionRow(
                              Provider.of<FacilityProvider>(context,
                                      listen: false)
                                  .places
                                  .map((place) => place.title)
                                  .toList(),
                              _currentPopularPlace,
                              Locales.string(context, "choose_popular_place"),
                              onChanged: (value) {
                            setState(() {
                              _currentPopularPlace = value as String;
                            });
                          }),
                          const VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "choose_title"),
                            style: TextStyles.display9(),
                          ),
                          const VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: Locales.string(context, "example_title"),
                            controller: _titleController,
                            focusNode: _titleFocusNode,
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_addressFocusNode);
                            },
                            validator: (value) {
                              if (value!.length == 0) {
                                return Locales.string(
                                    context, "required_field");
                              }
                              return null;
                            },
                          ),
                          const VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "choose_location"),
                            style: TextStyles.display9(),
                          ),
                          const VerticalHorizontalHalfSizedBox(),
                          _buildLocationPicker(),
                          const VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "enter_address"),
                            style: TextStyles.display9(),
                          ),
                          const VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText:
                                Locales.string(context, "example_address"),
                            controller: _addressController,
                            focusNode: _addressFocusNode,
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_descriptionFocusNode);
                            },
                            validator: (value) {
                              if (value!.length == 0) {
                                return Locales.string(
                                    context, "required_field");
                              }
                              return null;
                            },
                          ),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "about_estate"),
                            style: TextStyles.display9(),
                          ),
                          const VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: Locales.string(context, "about_estate"),
                            maxLines: 8,
                            maxLength: _descriptionMaxLength,
                            controller: _descriptionController,
                            focusNode: _descriptionFocusNode,
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_announcerFocusNode);
                            },
                            validator: (value) {
                              if (value!.length == 0) {
                                return Locales.string(
                                    context, "required_field");
                              }
                              return null;
                            },
                          ),
                          const VerticalHorizontalHalfSizedBox(),
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
                          const VerticalHorizontalHalfSizedBox(),
                          BookedDaysHint(),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "contact"),
                            style: TextStyles.display9(),
                          ),
                          const VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: Locales.string(context, "fullname"),
                            controller: _announcerController,
                            focusNode: _announcerFocusNode,
                            validation: false,
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_phoneFocusNode);
                            },
                          ),
                          const VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: Locales.string(context, "phone"),
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            isPhone: true,
                            onSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_weekdayPriceFocusNode);
                            },
                          ),
                          const VerticalHorizontalHalfSizedBox(),
                          Text(
                            Locales.string(context, "capacities"),
                            style: TextStyles.display9(),
                          ),
                          VerticalHorizontalSizedBox(),
                          Text("Mehmonlar soni: "),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                child: Icon(Icons.people),
                              ),
                              SizedBox(
                                width: 40.w,
                                child: CupertinoSpinBox(
                                  min: 0,
                                  max: 50,
                                  value: _people.toDouble(),
                                  onChanged: (value) {
                                    _people = value.toInt();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Text("Yotoqlar soni: "),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                child: Icon(Icons.bed),
                              ),
                              SizedBox(
                                width: 40.w,
                                child: CupertinoSpinBox(
                                  min: 0,
                                  max: 50,
                                  value: _beds.toDouble(),
                                  onChanged: (value) {
                                    _beds = value.toInt();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Text("Basseynlar soni: "),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                child: Icon(Icons.pool),
                              ),
                              SizedBox(
                                width: 40.w,
                                child: CupertinoSpinBox(
                                  min: 0,
                                  max: 50,
                                  value: _pools.toDouble(),
                                  onChanged: (value) {
                                    _pools = value.toInt();
                                  },
                                ),
                              ),
                            ],
                          ),
                          VerticalHorizontalSizedBox(),
                          Text(
                            Locales.string(context, "price"),
                            style: TextStyles.display9(),
                          ),
                          const VerticalHorizontalHalfSizedBox(),
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
                                  onSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(_weekendPriceFocusNode);
                                  },
                                  validator: (value) {
                                    if (value!.length == 0) {
                                      return Locales.string(
                                          context, "required_field");
                                    }
                                    return null;
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
                                  onSubmitted: (value) {},
                                  validator: (value) {
                                    if (value!.length == 0) {
                                      return Locales.string(
                                          context, "required_field");
                                    }
                                    return null;
                                  },
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
                                await updateData(context);
                              } else {
                                dynamic data = await sendData(context);
                                if (data != null) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  Navigator.of(context).pushNamed(
                                      PlansScreen.routeName,
                                      arguments: {"data": data});
                                }
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

  Widget _buildMainImagePicker({
    dynamic? photo,
    Function? callback,
    double? width,
    double? height,
    bool uploading = false,
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
                : (_isEditing && photo.runtimeType.toString() == "String")
                    ? Image.network(
                        fixMediaUrl(photo),
                        fit: BoxFit.cover,
                      )
                    : (uploading
                        ? Transform.scale(
                            scale: 0.5,
                            child: CircularProgressIndicator(),
                          )
                        : Image.file(
                            photo as File,
                            fit: BoxFit.cover,
                          )),
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
          (index) {
            if (_extraImages[index] == null) {
              Asset? asset = (images.length > index) ? images[index] : null;
              return ImageBox(
                onTap: loadAssets,
                photo: asset,
                size: (100.w - 3.5 * defaultPadding) / 4,
                onDelete: () {
                  setState(() {
                    _extraImagesLoading[index] = true;
                  });
                  Provider.of<CreateEstateProvider>(context, listen: false)
                      .removePhoto(_extraImagesId[index])
                      .then((value) {
                    _extraImages.removeAt(index);
                    _extraImages.add(null);
                    images.removeAt(index);
                    _extraImagesId.removeAt(index);
                    _extraImagesId.add(0);
                    setState(() {
                      _extraImagesLoading[index] = false;
                      _currentExtraImageIndex -= 1;
                    });
                  });
                },
              );
            } else {
              return ImageBox(
                onTap: loadAssets,
                image: _extraImages[index],
                size: (100.w - 3.5 * defaultPadding) / 4,
                onDelete: () {
                  setState(() {
                    _extraImagesLoading[index] = true;
                  });
                  Provider.of<CreateEstateProvider>(context, listen: false)
                      .removePhoto(_extraImagesId[index])
                      .then((value) {
                    _extraImages.removeAt(index);
                    _extraImages.add(null);
                    _extraImagesId.removeAt(index);
                    _extraImagesId.add(0);
                    setState(() {
                      _extraImagesLoading[index] = false;
                      _currentExtraImageIndex -= 1;
                    });
                  });
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSelectionRow(List<String> values, value, String placeHolder,
      {void Function(String?)? onChanged}) {
    return Container(
      height: 45,
      margin: EdgeInsets.only(top: 10),
      child: DropdownSearch<String>(
        mode: Mode.BOTTOM_SHEET,
        showSelectedItems: true,
        items: values,
        onChanged: onChanged,
        selectedItem: value,
      ),
    );
  }

  _showGoogleMap(BuildContext context) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(),
        settings: RouteSettings(
          arguments: {"longtitude": _longtitude, "latitute": _latitute},
        ),
      ),
    );
    if (data["street"] != "") {
      _locationName += data["street"];
      _locationName += ", ";
    }
    if (data["subAdministrativeArea"] != "") {
      _locationName += data["subAdministrativeArea"];
      _locationName += ", ";
    }
    if (data["administrativeArea"] != "") {
      _locationName += data["administrativeArea"];
      _locationName += ", ";
    }
    if (data["country"] != "") {
      _locationName += data["country"];
    }
    _longtitude = data["position"].longitude;
    _latitute = data["position"].latitude;
    setState(() {
      _addressController.text = _locationName;
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
                          style: const TextStyle(
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
                        style: const TextStyle(
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
    return Visibility(
      visible: _filtersOpen,
      child: Wrap(
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
      ),
    );
  }

  Widget _buildCalendar() {
    return (_isLoading && _selectedDays.length == 0)
        ? Container()
        : TableCalendar(
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
                shape: BoxShape.rectangle,
              ),
              defaultDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                shape: BoxShape.rectangle,
              ),
              todayDecoration: BoxDecoration(
                color: lightPurple,
                borderRadius: BorderRadius.circular(5),
                shape: BoxShape.rectangle,
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
    return Visibility(
      visible: display,
      child: Text(
        errorText,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
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
    return const SizedBox(height: defaultPadding);
  }
}

class ImageBox extends StatefulWidget {
  final void Function()? onTap;
  final Asset? photo;
  final String? image;
  final double size;
  final bool isUpdating;
  final void Function()? onDelete;

  const ImageBox({
    Key? key,
    this.onTap,
    this.photo,
    this.image,
    required this.size,
    this.isUpdating = false,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ImageBox> createState() => _ImageBoxState();
}

class _ImageBoxState extends State<ImageBox> {
  getContent(Asset? photo, String? image) {
    if (photo == null && image == null) {
      return Center(
        child: Image.asset(
          "assets/images/fi-rr-camera.png",
          scale: 1.5,
        ),
      );
    }
    return Stack(
      children: [
        photo == null
            ? CachedNetworkImage(
                imageUrl: image.toString(),
                height: widget.size.toDouble(),
                width: widget.size.toDouble(),
              )
            : AssetThumb(
                asset: photo,
                width: widget.size.toInt(),
                height: widget.size.toInt(),
              ),
        Positioned(
          right: 8,
          top: 8,
          child: GestureDetector(
            onTap: widget.onDelete,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: lessNormalGrey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: widget.size,
            height: widget.size,
            child: getContent(widget.photo, widget.image),
          ),
        ),
      ),
    );
  }
}
