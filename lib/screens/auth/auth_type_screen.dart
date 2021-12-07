import 'package:dachaturizm/components/fluid_big.dart';
import 'package:dachaturizm/components/text_link.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/app/home_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
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
    final value = ModalRoute.of(context)?.settings.arguments;
    print(value);

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      onPress: () {
                        Navigator.of(context)
                            .pushNamed(RegisterScreen.routeName);
                      },
                    ),
                    FluidBigButton(
                      Locales.string(context, "log_in"),
                      onPress: () {
                        Navigator.of(context).pushNamed(LoginScreen.routeName);
                      },
                    ),
                    SizedBox(
                      height: defaultPadding * 2,
                    ),
                    TextLinkButton(Locales.string(context, "skip"), () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setBool("noAuth", true);
                      Navigator.of(context)
                          .pushReplacementNamed(HomePageScreen.routeName);
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
