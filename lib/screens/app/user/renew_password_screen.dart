import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/password_input.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class RenewPasswordScreen extends StatefulWidget {
  const RenewPasswordScreen({Key? key}) : super(key: key);

  static const String routeName = "/renew-password";

  @override
  _RenewPasswordScreenState createState() => _RenewPasswordScreenState();
}

class _RenewPasswordScreenState extends State<RenewPasswordScreen> {
  bool _isLoading = false;
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  _changePassword() {
    if (_form.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<AuthProvider>(context, listen: false)
          .renewPassword(
              _currentPasswordController.text, _newPasswordController.text)
          .then((data) {
        setState(() {
          _isLoading = false;
        });
        String snackBarMessage = "";
        if (data["status"]) {
          snackBarMessage = Locales.string(context, "your_password_renewed");
        } else {
          print(data);
          switch (data["detail"]) {
            case "OLD_PASSWORD_WRONG":
              snackBarMessage = Locales.string(context, "old_password_wrong");
              break;
            default:
              snackBarMessage = Locales.string(context, "something_went_wrong");
              break;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackBarMessage),
            duration: Duration(seconds: 2),
          ),
        );
        if (data["status"]) {
          _currentPasswordController.text = "";
          _newPasswordController.text = "";
          _confirmPasswordController.text = "";
          Future.delayed(
            Duration(seconds: 2),
          ).then((_) async {
            Navigator.of(context).pop();
          });
        }
      });
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildNavigationalAppBar(
          context,
          Locales.string(context, "change_password"),
        ),
        floatingActionButton: Visibility(
          visible: !_isLoading,
          child: Container(
            width: 100.w - 1.8 * defaultPadding,
            child: FluidBigButton(
              text: Locales.string(context, "save"),
              onPress: _changePassword,
            ),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                height: 100.h,
                width: 100.w,
                padding: EdgeInsets.all(defaultPadding),
                child: SingleChildScrollView(
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Locales.string(context, "current_password"),
                          style:
                              TextStyles.display6().copyWith(color: darkPurple),
                        ),
                        SizedBox(height: defaultPadding * 3 / 4),
                        PasswordInputField(
                          controller: _currentPasswordController,
                          hintText: Locales.string(context, "current_password"),
                          validator: (value) {
                            if (value!.length == 0) {
                              return Locales.string(
                                context,
                                "fill_in_the_fields",
                              );
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 1.5 * defaultPadding),
                        Text(
                          Locales.string(context, "enter_new_password"),
                          style:
                              TextStyles.display6().copyWith(color: darkPurple),
                        ),
                        SizedBox(height: defaultPadding * 3 / 4),
                        PasswordInputField(
                          controller: _newPasswordController,
                          hintText:
                              Locales.string(context, "enter_new_password"),
                          validator: (value) {
                            if (value!.length == 0) {
                              return Locales.string(
                                context,
                                "fill_in_the_fields",
                              );
                            } else if (_newPasswordController.text !=
                                _confirmPasswordController.text) {
                              return Locales.string(
                                context,
                                "passwords_must_match",
                              );
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 1.5 * defaultPadding),
                        Text(
                          Locales.string(context, "repeat_new_password"),
                          style:
                              TextStyles.display6().copyWith(color: darkPurple),
                        ),
                        SizedBox(height: defaultPadding * 3 / 4),
                        PasswordInputField(
                          controller: _confirmPasswordController,
                          hintText:
                              Locales.string(context, "repeat_new_password"),
                          validator: (value) {
                            if (value!.length == 0) {
                              return Locales.string(
                                context,
                                "fill_in_the_fields",
                              );
                            } else if (_newPasswordController.text !=
                                _confirmPasswordController.text) {
                              return Locales.string(
                                context,
                                "passwords_must_match",
                              );
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 1.5 * defaultPadding),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
