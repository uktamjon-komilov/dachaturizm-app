import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ResetPasswordStep1 extends StatefulWidget {
  const ResetPasswordStep1({Key? key}) : super(key: key);

  @override
  _ResetPasswordStep1State createState() => _ResetPasswordStep1State();
}

class _ResetPasswordStep1State extends State<ResetPasswordStep1> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        body: Container(
          padding:
              EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 20),
          child: Column(
            children: [
              Center(
                child: LocaleText(
                  "reset_password",
                  style: TextStyle(
                    fontSize: 25,
                    color: normalOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 60),
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
              FluidBigButton(Locales.string(context, "register"),
                  onPress: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
