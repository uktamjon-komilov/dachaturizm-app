import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/screens/auth/otp_confirmation_screen.dart';
import 'package:dachaturizm/screens/styles/input.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LocaleText(
                      "register",
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
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    FluidBigButton(Locales.string(context, "register"),
                        onPress: () {
                      String phone = _phoneController.text.replaceAll(" ", "");
                      if (phone.length == 13) {
                        setState(() {
                          _isLoading = true;
                        });
                        Provider.of<AuthProvider>(context, listen: false)
                            .checkUser(phone)
                            .then((value) {
                          if (value["status"]) {
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pushNamed(
                                OTPConfirmationScreen.routeName,
                                arguments: phone);
                          }
                        });
                      }
                    }),
                    SizedBox(
                      height: 24,
                    ),
                    Wrap(
                      children: [
                        LocaleText(
                          "have_profile?",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 10),
                        TextLinkButton(Locales.string(context, "log_in"), () {
                          Navigator.of(context)
                              .pushReplacementNamed(LoginScreen.routeName);
                        }),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
