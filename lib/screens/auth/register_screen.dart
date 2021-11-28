import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/styles/input.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                  onPress: () {}),
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
                  TextLinkButton(Locales.string(context, "log_in"), () {}),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
