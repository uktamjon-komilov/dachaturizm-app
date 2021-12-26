import 'dart:io';

import 'package:dachaturizm/components/normal_input.dart';
import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/booking_day.dart';
import 'package:dachaturizm/models/currency_model.dart';
import 'package:dachaturizm/models/facility_model.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/facility_provider.dart';
import 'package:dachaturizm/providers/type_provider.dart';
import 'package:dachaturizm/screens/app/estate/location_picker_screen.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

class EstateCreationPageScreen extends StatefulWidget {
  const EstateCreationPageScreen({Key? key}) : super(key: key);

  @override
  _EstateCreationPageScreenState createState() =>
      _EstateCreationPageScreenState();
}

class _EstateCreationPageScreenState extends State<EstateCreationPageScreen> {
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isSubmitted = false;
  int _currentExtraImageIndex = 0;
  int _descriptionMaxLength = 1000;
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

  var _mainImage = null;
  List _extraImages = List.generate(8, (_) => null);
  int _currentSectionId = 0;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _announcerController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _weekdayPriceController = TextEditingController();
  TextEditingController _weekendPriceController = TextEditingController();
  int _currentCurrencyId = 0;
  List<int> _facilities = [];
  double _longtitude = 0.0;
  double _latitute = 0.0;
  String _locationName = "";

  List<String> get _bookedDays {
    return _selectedDays.map((day) => day.date).toList();
  }

  Future<dynamic> sendData() async {
    if (!_form.currentState!.validate() ||
        _mainImage == null ||
        _currentSectionId == 0 ||
        _currentCurrencyId == 0) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.bounceIn,
      );
      setState(() {
        _isSubmitted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("There is some error in filling the input fields.")));
      return;
    }
    Map<String, dynamic> data = {};
    data["photo"] = _mainImage;
    data["photos"] = _extraImages.where((image) => image != null).toList();
    data["estate_type"] = _currentSectionId.toString();
    data["title"] = _titleController.text;
    data["address"] = _addressController.text;
    data["longtitute"] = "0.0";
    data["latitute"] = "0.0";
    data["description"] = _descriptionController.text;
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
    data["is_published"] = "false";

    setState(() {
      _isUploading = true;
      _isSubmitted = false;
    });
    Provider.of<EstateProvider>(context, listen: false)
        .createEstate(data)
        .then((value) {
      print(value);
      setState(() {
        _isUploading = false;
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
        await _picker.pickImage(source: ImageSource.gallery);
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

  Widget _buildMainImagePicker(
      {image = null,
      callback = null,
      double width = 0.0,
      double height = 250,
      bool disabled = true,
      double iconScale = 1}) {
    width = width == 0.0 ? 100.w : width;

    return GestureDetector(
      onTap: () {
        if (disabled)
          return;
        else {
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
            child: image == null
                ? Center(
                    child: Image.asset(
                      "assets/images/fi-rr-camera.png",
                      scale: iconScale,
                    ),
                  )
                : Image.file(
                    image,
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
            image: _extraImages[index],
            callback: () => _selectExtraImage(index),
            disabled: index > _currentExtraImageIndex,
            iconScale: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionsRow(List<TypeModel> _sections) {
    return Wrap(
      children: [
        ..._sections.map((section) {
          return SmallButton(section.title,
              enabled: _currentSectionId == section.id, onPressed: () {
            setState(() {
              _currentSectionId = section.id;
            });
          });
        })
      ],
    );
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
                            ? "Please, tap to show your location on the map"
                            : "Please, tap to change your location",
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
          return Container(
            width: 170,
            child: CheckboxListTile(
              value: _facilities.contains(facility.id),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.all(0),
              dense: false,
              activeColor: normalOrange,
              selectedTileColor: lightPurple,
              onChanged: (change) {
                setState(() {
                  _facilities.add(facility.id);
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
        // return true;
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
    Future.delayed(Duration.zero).then((_) {
      Provider.of<FacilityProvider>(context, listen: false)
          .fetchAndSetFacilities()
          .then((facilities) {
        Provider.of<EstateTypesProvider>(context, listen: false)
            .fetchAndSetTypes()
            .then((_) {
          Provider.of<CurrencyProvider>(context, listen: false)
              .fetchAndSetCurrencies()
              .then((_) {
            setState(() {
              _isLoading = false;
            });
          });
        });
      });
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
    List<TypeModel> sections =
        Provider.of<EstateTypesProvider>(context, listen: false).items;
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
                        "Joylashtirilmoqda...",
                        style: TextStyle(
                          color: normalOrange,
                          fontSize: 20,
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
                      reverse: true,
                      controller: _scrollController,
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VerticalHorizontalSizedBox(),
                          Text1("Asosiy rasm"),
                          VerticalHorizontalHalfSizedBox(),
                          Text("Ushbu surat e'loningiz asosiy rasmi bo'ladi."),
                          VerticalHorizontalSizedBox(),
                          _buildMainImagePicker(
                            image: _mainImage,
                            callback: _selectMainImage,
                            disabled: false,
                          ),
                          ErrorText(
                            errorText: "Please, pick an image",
                            display: (_isSubmitted && _mainImage == null),
                          ),
                          VerticalHorizontalSizedBox(),
                          Text1("Gallareya"),
                          VerticalHorizontalSizedBox(),
                          _buildExtraImagesGrid(),
                          VerticalHorizontalHalfSizedBox(),
                          Text("*Umumiy maksimum 8ta rasm joylashingiz mumkin"),
                          VerticalHorizontalSizedBox(),
                          Text1("Bo'limni tanlang"),
                          _buildSectionsRow(sections),
                          VerticalHorizontalSizedBox(),
                          Text1("Sarlavhani kiriting"),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: "Masalan, Humsonda dacha arendaga...",
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
                          Text1("Manzilni kiriting"),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: "Masalan, Bo'stonliq tumani",
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
                          Text1("Xaritadan tanlang"),
                          VerticalHorizontalHalfSizedBox(),
                          _buildLocationPicker(),
                          VerticalHorizontalSizedBox(),
                          Text1("Tavsif"),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: "E'lon haqida...",
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
                              Text("Kamida 50ta belgi yozing"),
                              Text(
                                  "${_descriptionController.text.length}/${_descriptionMaxLength}"),
                            ],
                          ),
                          VerticalHorizontalSizedBox(),
                          Text1("Band kunlar (mavjud bo'lsa)"),
                          _buildCalendar(),
                          VerticalHorizontalHalfSizedBox(),
                          BookedDaysHint(),
                          VerticalHorizontalSizedBox(),
                          Text1("Filterlar qo'shish"),
                          VerticalHorizontalHalfSizedBox(),
                          _buildFacilitiesGrid(facilities),
                          VerticalHorizontalSizedBox(),
                          Text1("Aloqa"),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: "Ism",
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
                            hintText: "Telefon raqam",
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
                          Text1("Narx"),
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: "Hafta kunlari",
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
                          VerticalHorizontalHalfSizedBox(),
                          NormalTextInput(
                            hintText: "Dam olish kunlari",
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
                          _buildPriceTypeRow(currencies),
                          ErrorText(
                            errorText: "Please, choose a currency",
                            display: (_isSubmitted && _currentCurrencyId == 0),
                          ),
                          VerticalHorizontalSizedBox(),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? () {}
                                : () {
                                    sendData();
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(100.w - 2 * defaultPadding, 50),
                              primary: normalOrange,
                              // onPrimary: normalOrange.withOpacity(0.05),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isLoading
                                    ? Container(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Joylashtirish",
                                        style: TextStyle(
                                          color: _isLoading
                                              ? normalOrange
                                              : Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                              ],
                            ),
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

class BookedDaysHint extends StatelessWidget {
  const BookedDaysHint({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: normalOrange,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(width: 10),
        Text("Band qilingan kunlar"),
      ],
    );
  }
}
