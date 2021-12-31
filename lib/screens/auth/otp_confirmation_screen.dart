import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/auth/create_profile_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';

class OTPConfirmationScreen extends StatefulWidget {
  const OTPConfirmationScreen({Key? key}) : super(key: key);

  static String routeName = "/otp-confirmation";

  @override
  _OTPConfirmationScreenState createState() => _OTPConfirmationScreenState();
}

class _OTPConfirmationScreenState extends State<OTPConfirmationScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)?.settings.arguments as String;

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
                          "assets/images/logo.png",
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: defaultPadding * 1.5),
                        Text(
                          Locales.string(context, "confirm_otp_code"),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: defaultPadding / 2),
                        Text(
                          Locales.string(context,
                              "otp_code_has_been_sent_to_below_number"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            color: greyishLight,
                          ),
                        ),
                        SizedBox(height: 30),
                        OtpTextField(
                          numberOfFields: 5,
                          borderColor: normalOrange,
                          focusedBorderColor: normalOrange,
                          borderWidth: 1,
                          borderRadius: BorderRadius.circular(15),
                          fieldWidth: 60,
                          textStyle: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                          showFieldAsBox: true,
                          onCodeChanged: (String code) {},
                          onSubmit: (String verificationCode) {
                            checkCode(context, phone, verificationCode);
                          }, // end onSubmit
                        ),
                        SizedBox(height: defaultPadding * 1.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              Locales.string(context, "have_not_received_sms?"),
                              style: TextStyle(fontSize: 12),
                            ),
                            SizedBox(width: 10),
                            TextLinkButton(
                                Locales.string(context, "resend_sms"), () {
                              Provider.of<AuthProvider>(context, listen: false)
                                  .checkUser(phone)
                                  .then((value) {});
                            }),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void checkCode(context, phone, verificationCode) {
    setState(() {
      _isLoading = true;
    });
    Provider.of<AuthProvider>(context, listen: false)
        .checkCode(phone, verificationCode)
        .then((value) {
      if (value["status"]) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed(
            CreateProfileScreen.routeName,
            arguments: phone);
      } else {
        Navigator.of(context).pop();
      }
    });
  }
}
