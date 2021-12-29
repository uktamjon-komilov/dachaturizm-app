import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/styles/input.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  static String routeName = "/create-profile";

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  bool _hidePassword = true;
  bool _agreeTerms = false;
  bool _somethingWrong = false;
  bool _userAlreadyExists = false;

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  FocusNode _firstNameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _newPasswordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)?.settings.arguments as String;

    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LocaleText(
                      "create_profile",
                      style: TextStyle(
                        fontSize: 25,
                        color: normalOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    _buildTextInput(
                      context,
                      hintText: "first_name_hint_text",
                      iconData: Icons.person,
                      focusNode: _firstNameFocusNode,
                      nextFocusNode: _lastNameFocusNode,
                      controller: _firstNameController,
                    ),
                    _buildTextInput(
                      context,
                      hintText: "last_name_hint_text",
                      iconData: Icons.person,
                      focusNode: _lastNameFocusNode,
                      nextFocusNode: _newPasswordFocusNode,
                      controller: _lastNameController,
                    ),
                    _buildTextInput(
                      context,
                      hintText: "new_password_hint",
                      iconData: Icons.lock,
                      suffixIcon: Icons.remove_red_eye,
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                      obscureText: _hidePassword,
                      focusNode: _newPasswordFocusNode,
                      nextFocusNode: _newPasswordFocusNode,
                      controller: _newPasswordController,
                    ),
                    _buildTextInput(
                      context,
                      hintText: "new_confirm_password_hint",
                      iconData: Icons.lock,
                      suffixIcon: Icons.remove_red_eye,
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                      obscureText: _hidePassword,
                      focusNode: _confirmPasswordFocusNode,
                      controller: _confirmPasswordController,
                    ),
                    CheckboxListTile(
                      title: LocaleText("i_agree_to_the_terms"),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _agreeTerms,
                      activeColor: normalOrange,
                      onChanged: (value) {
                        setState(() {
                          _agreeTerms = !_agreeTerms;
                        });
                      },
                    ),
                    TextLinkButton(Locales.string(context, "terms_of_use"), () {
                      UrlLauncher.launch(
                          "http://45.129.170.152/staticpages/terms-of-use");
                    }),
                    SizedBox(
                      height: 16,
                    ),
                    _somethingWrong
                        ? LocaleText(
                            "something_went_wrong_form_text",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          )
                        : Container(),
                    _userAlreadyExists
                        ? LocaleText(
                            "user_already_exists_with_this_phone",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 16,
                    ),
                    (_agreeTerms)
                        ? FluidBigButton(
                            Locales.string(context, "create_profile"),
                            onPress: () {
                            if (_form.currentState!.validate()) {
                              setState(() {
                                _somethingWrong = false;
                              });
                              if (_userAlreadyExists) {
                                Navigator.of(context).pop();
                              }
                              Provider.of<AuthProvider>(context, listen: false)
                                  .signUp(
                                      phone,
                                      _newPasswordController.text,
                                      _firstNameController.text,
                                      _lastNameController.text)
                                  .then((value) {
                                if (value.containsKey("status") &&
                                    value["status"] == false) {
                                  setState(() {
                                    _somethingWrong = true;
                                  });
                                } else if (value.containsKey("id") &&
                                    value["id"] > 0) {
                                  Navigator.of(context)
                                      .popAndPushNamed(LoginScreen.routeName);
                                } else {
                                  setState(() {
                                    _userAlreadyExists = true;
                                  });
                                }
                              });
                            }
                          })
                        : Container(
                            height: 73,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(
    BuildContext context, {
    String hintText = "",
    IconData iconData = Icons.person,
    bool obscureText = false,
    var suffixIcon = null,
    var onPressed = null,
    var focusNode = null,
    var nextFocusNode = null,
    var controller = null,
    var validator = null,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: TextFormField(
        controller: controller != null ? controller : null,
        focusNode: focusNode != null ? focusNode : null,
        decoration: InputDecoration(
          border: InputStyles.inputBorder(),
          focusedBorder: InputStyles.focusBorder(),
          labelText: Locales.string(context, hintText),
          floatingLabelStyle: TextStyle(color: normalOrange),
          prefixIcon: Icon(iconData),
          hintText: Locales.string(context, hintText),
          suffixIcon: (suffixIcon != null && onPressed != null)
              ? IconButton(
                  icon: Icon(suffixIcon as IconData), onPressed: onPressed)
              : null,
        ),
        validator: (value) {
          if (value?.length == 0) {
            return Locales.string(context, hintText) +
                " " +
                Locales.string(context, "input_must_be");
          } else if (obscureText &&
              _newPasswordController.text != _confirmPasswordController.text) {
            return Locales.string(context, "passwords_must_match");
          } else if (obscureText && value!.length < 8) {
            return Locales.string(context, "password_min_length_amount");
          }
          return null;
        },
        onFieldSubmitted: (value) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        obscureText: obscureText,
      ),
    );
  }
}
