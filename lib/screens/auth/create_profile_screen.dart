import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/styles/input.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  bool _hidePassword = true;
  bool _agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(defaultPadding),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LocaleText(
                    "create_profile",
                    style: TextStyle(
                      fontSize: 25,
                      color: normalOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  _buildTextInput(
                    context,
                    hintText: "first_name_hint_text",
                    iconData: Icons.person,
                  ),
                  _buildTextInput(
                    context,
                    hintText: "last_name_hint_text",
                    iconData: Icons.person,
                  ),
                  _buildTextInput(
                    context,
                    hintText: "new_password_hint",
                    suffixIcon: Icons.remove_red_eye,
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                    obscureText: _hidePassword,
                  ),
                  _buildTextInput(
                    context,
                    hintText: "new_confirm_password_hint",
                    suffixIcon: Icons.remove_red_eye,
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },
                    obscureText: _hidePassword,
                  ),
                  CheckboxListTile(
                    title: LocaleText("i_agree_to_the_terms"),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _agreeTerms,
                    activeColor: normalOrange,
                    onChanged: (value) {
                      setState(() {
                        _agreeTerms = !_agreeTerms;
                      });
                    },
                  ),
                  TextLinkButton("terms_of_use", () {}),
                  SizedBox(
                    height: 32,
                  ),
                  _agreeTerms
                      ? FluidBigButton(
                          Locales.string(context, "create_profile"),
                          onPress: () {})
                      : Container(
                          height: 73,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(
    BuildContext context, {
    String hintText = "",
    IconData iconData = Icons.person,
    bool obscureText = false,
    var suffixIcon = null,
    var onPressed = null,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: TextFormField(
        decoration: InputDecoration(
          border: InputStyles.inputBorder(),
          focusedBorder: InputStyles.focusBorder(),
          prefixIcon: Icon(
            iconData,
          ),
          hintText: Locales.string(context, hintText),
          suffixIcon: (suffixIcon != null && onPressed != null)
              ? IconButton(
                  icon: Icon(suffixIcon as IconData), onPressed: onPressed)
              : null,
        ),
        obscureText: obscureText,
      ),
    );
  }
}
