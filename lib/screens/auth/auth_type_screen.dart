import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/components/fluid_outlined_button.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTypeScreen extends StatefulWidget {
  const AuthTypeScreen({Key? key}) : super(key: key);

  static String routeName = "/auth-type";

  @override
  _AuthTypeScreenState createState() => _AuthTypeScreenState();
}

class _AuthTypeScreenState extends State<AuthTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo-turizm.png",
              width: 120,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 90),
            FluidBigButton(
              text: Locales.string(context, "register"),
              onPress: () {
                Navigator.of(context).pushNamed(RegisterScreen.routeName);
              },
            ),
            SizedBox(height: 12),
            FluidOutlinedButton(
              text: Locales.string(context, "log_in"),
              onPress: () {
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
            ),
            SizedBox(height: 72),
            TextLinkButton(Locales.string(context, "skip"), () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool("noAuth", true);
              Navigator.of(context)
                  .pushReplacementNamed(NavigationalAppScreen.routeName);
            }),
          ],
        ),
      ),
    );
  }
}
