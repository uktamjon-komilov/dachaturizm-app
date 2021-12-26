import 'dart:io';

import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  static String routeName = "/edit-profile";

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = false;

  var _profileImage = null;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  Future<dynamic> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery);
    return imageFile == null ? null : imageFile.path;
  }

  Future<void> _selectProfileImage() async {
    final image = await _selectImage();
    if (image == null) {
      setState(() {
        _profileImage = null;
      });
      return;
    }

    setState(() {
      _profileImage = File(image as String);
    });
  }

  _saveDetails() async {
    Map<String, dynamic> data = {
      "first_name": _firstNameController.text,
      "last_name": _lastNameController.text,
      "phone": _phoneController.text.replaceAll(" ", ""),
    };

    if (_profileImage != null) {
      data["photo"] = await MultipartFile.fromFile(_profileImage.path);
      _profileImage = null;
    }
    FormData formData = FormData.fromMap(data);
    setState(() {
      _isLoading = true;
    });
    callWithAuth(context, () {
      Provider.of<AuthProvider>(context, listen: false)
          .updateUser(formData)
          .then((value) {
        Provider.of<AuthProvider>(context, listen: false)
            .getUserData()
            .then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      });
    });
  }

  Future _refreshUserSettings() async {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<AuthProvider>(context, listen: false).getUserData().then((_) {
        setState(() {
          _isLoading = false;
          _firstNameController.text =
              Provider.of<AuthProvider>(context, listen: false).user!.firstName;
          _lastNameController.text =
              Provider.of<AuthProvider>(context, listen: false).user!.lastName;
          _phoneController.text =
              Provider.of<AuthProvider>(context, listen: false).user!.phone;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<AuthProvider>(context, listen: false).getUserData().then((_) {
        setState(() {
          _isLoading = false;
          _firstNameController.text =
              Provider.of<AuthProvider>(context, listen: false).user!.firstName;
          _lastNameController.text =
              Provider.of<AuthProvider>(context, listen: false).user!.lastName;
          _phoneController.text =
              Provider.of<AuthProvider>(context, listen: false).user!.phone;
        });
      });
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = Provider.of<AuthProvider>(context, listen: false).user;

    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(4);
        return true;
      },
      child: SafeArea(
        child: (_isLoading || user == null)
            ? Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: Text(Locales.string(context, "editing")),
                  leading: IconButton(
                    onPressed: () {
                      Provider.of<NavigationScreenProvider>(context,
                              listen: false)
                          .changePageIndex(4);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _saveDetails();
                      },
                      child: Text(
                        Locales.string(context, "save"),
                        style: TextStyle(
                          color: normalOrange,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                body: Container(
                  width: 100.w,
                  padding: EdgeInsets.all(defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _selectProfileImage();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: defaultPadding),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25.w),
                            child: Container(
                              width: 50.w,
                              height: 50.w,
                              child: Stack(
                                children: [
                                  _profileImage != null
                                      ? Image.file(
                                          _profileImage,
                                          fit: BoxFit.cover,
                                          width: 100.w,
                                          height: 100.w,
                                        )
                                      : user.photo == null
                                          ? Image.asset(
                                              "assets/images/panda.jpg",
                                              fit: BoxFit.cover,
                                              width: 100.w,
                                              height: 100.w,
                                            )
                                          : Image.network(
                                              fixMediaUrl(user.photo),
                                              fit: BoxFit.cover,
                                              width: 100.w,
                                              height: 100.w,
                                            ),
                                  Center(
                                    child:
                                        Image.asset("assets/images/camera.png"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: defaultPadding * 1.5),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: Locales.string(context, "first_name"),
                          label: Text(Locales.string(context, "first_name")),
                        ),
                      ),
                      SizedBox(height: defaultPadding * 1.5),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                            hintText: Locales.string(context, "last_name"),
                            label: Text(Locales.string(context, "last_name"))),
                      ),
                      SizedBox(height: defaultPadding * 1.5),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                            hintText: Locales.string(context, "phone"),
                            label: Text(Locales.string(context, "phone"))),
                        inputFormatters: [
                          MaskTextInputFormatter(mask: "+998 ## ### ## ##")
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
