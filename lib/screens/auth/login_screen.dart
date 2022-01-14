import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/password_input.dart';
import 'package:dachaturizm/components/phone_input.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/clear_phone_number.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/auth/register_screen.dart';
import 'package:dachaturizm/screens/auth/reset_password_step1_screen.dart';
import 'package:dachaturizm/styles/input.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static String routeName = "/login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _hidePassword = true;
  bool _wrongCredentials = false;

  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Form(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo-turizm.png",
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: defaultPadding * 1.5),
                    Text(
                      Locales.string(context, "log_in"),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: defaultPadding / 2),
                    Text(
                      Locales.string(context, "welcome"),
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
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                      onChanged: (value) {
                        if (_wrongCredentials) {
                          setState(() {
                            _wrongCredentials = false;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 8),
                    PasswordInputField(
                      focusNode: _passwordFocusNode,
                      controller: _passwordController,
                      onChanged: (value) {
                        if (_wrongCredentials) {
                          setState(() {
                            _wrongCredentials = false;
                          });
                        }
                      },
                    ),
                    Visibility(
                      visible: _wrongCredentials,
                      child: Padding(
                        padding: const EdgeInsets.only(top: defaultPadding),
                        child: Text(
                          Locales.string(context, "wrong_login_and_password"),
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: defaultPadding),
                    FluidBigButton(
                      text: Locales.string(context, "log_in"),
                      onPress: login,
                      loading: _isLoading,
                    ),
                    SizedBox(height: 1.5 * defaultPadding),
                    TextLinkButton(Locales.string(context, "forgot_password?"),
                        () {
                      Navigator.of(context)
                          .pushReplacementNamed(ResetPasswordStep1.routeName);
                    }),
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
                        TextLinkButton(Locales.string(context, "register"), () {
                          Navigator.of(context)
                              .pushReplacementNamed(RegisterScreen.routeName);
                        }),
                      ],
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

  login() {
    setState(() {
      _isLoading = true;
    });
    String phone = clearPhoneNumber(_phoneController.text);
    String password = _passwordController.text;
    Provider.of<AuthProvider>(context, listen: false)
        .login(phone, password)
        .then((value) async {
      if (value.containsKey("status")) {
        setState(() {
          _wrongCredentials = true;
          _isLoading = false;
        });
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("noAuth", true);
        Navigator.of(context)
          ..popUntil(ModalRoute.withName(NavigationalAppScreen.routeName))
          ..pushReplacementNamed(NavigationalAppScreen.routeName);
      }
    });
  }
}
