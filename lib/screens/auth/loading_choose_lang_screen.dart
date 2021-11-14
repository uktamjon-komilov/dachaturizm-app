import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import "package:flutter_svg/flutter_svg.dart";
import '../../constants.dart';
import '../../components/fluid_big.dart';

class LoadingChooseLangScreen extends StatefulWidget {
  const LoadingChooseLangScreen({Key? key}) : super(key: key);

  @override
  _LoadingChooseLangScreenState createState() =>
      _LoadingChooseLangScreenState();
}

class _LoadingChooseLangScreenState extends State<LoadingChooseLangScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Center(
              child: SvgPicture.asset("assets/images/all_lang.svg"),
            ),
          ),
          SizedBox(
            height: defaultPadding,
          ),
          Text(
            "Tilni tanlang",
            style: TextStyle(
              color: darkPurple,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: defaultPadding * 2,
          ),
          LangOption(
            lang: "UZ",
            icon: "assets/images/flag_uz.png",
            selected: true,
          ),
          LangOption(lang: "UZ", icon: "assets/images/flag_ru.png"),
          LangOption(lang: "UZ", icon: "assets/images/flag_en.png"),
          SizedBox(
            height: defaultPadding * 3,
          ),
          FluidBigButton("Keyingisi"),
        ],
      ),
    ));
  }
}

class LangOption extends StatelessWidget {
  const LangOption({
    this.selected = false,
    this.lang = "",
    this.icon = "",
    Key? key,
  }) : super(key: key);

  final bool selected;
  final String lang;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: EdgeInsets.symmetric(
          vertical: defaultPadding / 4, horizontal: defaultPadding / 2),
      decoration: BoxDecoration(
          color: selected ? Color(0xFFFFEDC7) : null,
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Image.asset(
            icon,
          ),
          SizedBox(
            width: 2 * defaultPadding / 3,
          ),
          Text(
            lang,
            style: TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.w600,
              fontSize: 35,
            ),
          )
        ],
      ),
    );
  }
}
