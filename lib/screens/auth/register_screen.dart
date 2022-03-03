import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/phone_input.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/screens/auth/otp_confirmation_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  static String routeName = "/register";

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _userAlreadyExists = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Locales.string(context, "register"),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: defaultPadding / 2),
                      Text(
                        Locales.string(context, "new_profile_new_results"),
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
                      ),
                      SizedBox(height: defaultPadding),
                      FluidBigButton(
                        text: Locales.string(context, "next"),
                        onPress: () {
                          String phone = _phoneController.text
                              .replaceAll(" ", "")
                              .replaceAll("(", "")
                              .replaceAll(")", "");
                          if (phone.length > 11) {
                            setState(() {
                              _isLoading = true;
                            });
                            Provider.of<AuthProvider>(context, listen: false)
                                .checkUser(phone)
                                .then((value) {
                              setState(() {
                                _isLoading = false;
                              });
                              if (value["status"]) {
                                Navigator.of(context).pushNamed(
                                    OTPConfirmationScreen.routeName,
                                    arguments: phone);
                              } else {
                                setState(() {
                                  _userAlreadyExists = true;
                                });
                              }
                            });
                          }
                        },
                      ),
                      SizedBox(height: defaultPadding * 0.75),
                      Visibility(
                        visible: _userAlreadyExists,
                        child: Text(
                          Locales.string(
                              context, "user_already_exists_with_this_phone"),
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(height: defaultPadding * 0.75),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            Locales.string(context, "have_profile?"),
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 10),
                          TextLinkButton(Locales.string(context, "log_in"), () {
                            Navigator.of(context)
                                .pushReplacementNamed(LoginScreen.routeName);
                          }),
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
