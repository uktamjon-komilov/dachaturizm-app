import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/auth/register_screen.dart';
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
          padding: const EdgeInsets.all(defaultPadding),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LocaleText(
                  "log_in",
                  style: TextStyle(
                    fontSize: 25,
                    color: normalOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                TextFormField(
                  focusNode: _phoneFocusNode,
                  controller: _phoneController,
                  inputFormatters: [
                    MaskTextInputFormatter(mask: "+998 ## ### ## ##")
                  ],
                  decoration: InputDecoration(
                    border: InputStyles.inputBorder(),
                    focusedBorder: InputStyles.focusBorder(),
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                    ),
                    hintText: Locales.string(context, "phone_number_hint"),
                  ),
                  keyboardType: TextInputType.number,
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
                SizedBox(
                  height: 20,
                ),
                TextField(
                  focusNode: _passwordFocusNode,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: InputStyles.inputBorder(),
                    focusedBorder: InputStyles.focusBorder(),
                    prefixIcon: Icon(
                      Icons.lock,
                    ),
                    hintText: Locales.string(context, "password_hint"),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                      ),
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _hidePassword,
                  onChanged: (value) {
                    if (_wrongCredentials) {
                      setState(() {
                        _wrongCredentials = false;
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                _wrongCredentials
                    ? LocaleText(
                        "wrong_login_and_password",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 20,
                ),
                TextLinkButton(
                    Locales.string(context, "forgot_password?"), () {}),
                SizedBox(
                  height: 32,
                ),
                FluidBigButton(Locales.string(context, "log_in"),
                    onPress: () async {
                  String phone = _phoneController.text.replaceAll(" ", "");
                  String password = _passwordController.text;
                  Provider.of<AuthProvider>(context, listen: false)
                      .login(phone, password)
                      .then((value) async {
                    if (value.containsKey("status")) {
                      setState(() {
                        _wrongCredentials = true;
                      });
                    } else {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("noAuth", true);
                      Navigator.of(context)
                        ..pop()
                        ..pushReplacementNamed(NavigationalAppScreen.routeName);
                    }
                  });
                }),
                SizedBox(
                  height: 24,
                ),
                Wrap(
                  children: [
                    LocaleText(
                      "no_profile?",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: 10),
                    TextLinkButton(Locales.string(context, "register"), () {
                      Navigator.of(context)
                          .pushReplacementNamed(RegisterScreen.routeName);
                    }),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
