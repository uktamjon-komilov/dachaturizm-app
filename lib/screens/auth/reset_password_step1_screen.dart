import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/phone_input.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/clear_phone_number.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/screens/auth/otp_confirmation_screen.dart';
import 'package:dachaturizm/screens/auth/register_screen.dart';
import 'package:dachaturizm/screens/auth/reset_password_step2_screen.dart';
import 'package:dachaturizm/styles/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class ResetPasswordStep1 extends StatefulWidget {
  const ResetPasswordStep1({Key? key}) : super(key: key);

  static const String routeName = "/reset-password1";

  @override
  _ResetPasswordStep1State createState() => _ResetPasswordStep1State();
}

class _ResetPasswordStep1State extends State<ResetPasswordStep1> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _wrongCredentials = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo-icon.png",
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: defaultPadding * 1.5),
                        Text(
                          Locales.string(context, "reset_password"),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: defaultPadding / 2),
                        Text(
                          Locales.string(context, "enter_your_phone_number"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            color: greyishLight,
                          ),
                        ),
                        SizedBox(height: 28),
                        PhoneNumberField(
                          controller: _phoneController,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          onChanged: (value) {
                            _wrongCredentials = false;
                          },
                        ),
                        Visibility(
                          visible: _wrongCredentials,
                          child: Padding(
                            padding: const EdgeInsets.only(top: defaultPadding),
                            child: Text(
                              Locales.string(context, "wrong_phone_number"),
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: defaultPadding),
                        FluidBigButton(
                          text: Locales.string(context, "next"),
                          onPress: () => resetPasswordStep1(context),
                        ),
                        SizedBox(height: defaultPadding * 1.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Locales.string(context, "no_profile?"),
                              style: TextStyle(fontSize: 12),
                            ),
                            SizedBox(width: 10),
                            TextLinkButton(Locales.string(context, "register"),
                                () {
                              Navigator.of(context).pushReplacementNamed(
                                  RegisterScreen.routeName);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  resetPasswordStep1(BuildContext context) async {
    String phone = clearPhoneNumber(_phoneController.text);
    if (phone.length >= 12) {
      setState(() {
        _isLoading = true;
      });
      Map<String, bool> result =
          await Provider.of<AuthProvider>(context, listen: false)
              .resetPassword1(phone);
      print(result);
      if (result["status"] as bool) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context)
            .pushNamed(ResetPasswordStep2.routeName, arguments: phone);
      } else {
        setState(() {
          _isLoading = false;
          _wrongCredentials = true;
        });
      }
    }
  }
}
