import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../components/fluid_big.dart';
import '../../components/text_link.dart';
import '../../constants.dart';

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
                  FluidBigButton("Ro'yhatdan o'tish"),
                  FluidBigButton("Kirish"),
                  SizedBox(
                    height: defaultPadding * 2,
                  ),
                  TextLinkButton("O'tkazib yuborish", "/home-page")
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
