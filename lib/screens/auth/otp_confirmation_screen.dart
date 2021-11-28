import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/styles/input.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class OTPConfirmationScreen extends StatefulWidget {
  const OTPConfirmationScreen({Key? key}) : super(key: key);

  @override
  _OTPConfirmationScreenState createState() => _OTPConfirmationScreenState();
}

class _OTPConfirmationScreenState extends State<OTPConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LocaleText(
                "confirm_otp_code",
                style: TextStyle(
                  fontSize: 25,
                  color: normalOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                Locales.string(
                        context, "otp_code_has_been_sent_to_below_number") +
                    "+998 99 517 53 47",
                style: TextStyle(
                    fontSize: 17,
                    color: normalGrey,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              OtpTextField(
                numberOfFields: 5,
                borderColor: normalOrange,
                focusedBorderColor: normalOrange,
                fieldWidth: 60,
                textStyle: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                showFieldAsBox: true,
                onCodeChanged: (String code) {
                  print(code);
                },
                onSubmit: (String verificationCode) {
                  print(verificationCode);
                }, // end onSubmit
              ),
              SizedBox(
                height: 32,
              ),
              FluidBigButton(Locales.string(context, "confirm"),
                  onPress: () {}),
              SizedBox(
                height: 24,
              ),
              Wrap(
                children: [
                  LocaleText(
                    "have_not_received_sms?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 10),
                  TextLinkButton(Locales.string(context, "resend_sms"), () {}),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
