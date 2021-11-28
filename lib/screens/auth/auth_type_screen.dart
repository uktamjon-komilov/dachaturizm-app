import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthType extends StatefulWidget {
  const AuthType({Key? key}) : super(key: key);

  @override
  _AuthTypeState createState() => _AuthTypeState();
}

class _AuthTypeState extends State<AuthType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 2),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        scale: 2.5,
                      ),
                    ),
                    SizedBox(
                      height: defaultPadding * 2,
                    ),
                    Text(
                      "Tez. Oson. Qulay.",
                      style: TextStyle(
                        color: darkPurple,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FluidBigButton(
                    Locales.string(context, "register"),
                    onPress: () {},
                  ),
                  FluidBigButton(
                    Locales.string(context, "log_in"),
                    onPress: () {},
                  ),
                  SizedBox(
                    height: defaultPadding * 2,
                  ),
                  TextLinkButton(Locales.string(context, "next"), () {})
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
