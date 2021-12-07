import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/banner_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:dachaturizm/screens/app/home/home_screen.dart';
import 'package:dachaturizm/screens/app/home/listing_screen.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/app/user/change_language.dart';
import 'package:dachaturizm/screens/auth/auth_type_screen.dart';
import 'package:dachaturizm/screens/auth/create_profile_screen.dart';
import 'package:dachaturizm/screens/auth/otp_confirmation_screen.dart';
import 'package:dachaturizm/screens/auth/register_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/screens/loading/choose_language_screen.dart';
import 'package:dachaturizm/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'package:provider/provider.dart';
import 'providers/type_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(["en", "uz", "ru"]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: AuthProvider(),
          ),
          ChangeNotifierProvider.value(
            value: BannerProvider(),
          ),
          ChangeNotifierProvider.value(
            value: EstateTypesProvider(),
          ),
          ChangeNotifierProvider.value(
            value: EstateProvider(),
          ),
        ],
        child: MaterialApp(
          title: LocaleText("appbar_text").toString(),
          localizationsDelegates: Locales.delegates,
          supportedLocales: Locales.supportedLocales,
          locale: locale,
          theme: new ThemeData(
            primarySwatch: Colors.grey,
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: darkPurple,
                  displayColor: darkPurple,
                ),
            primaryTextTheme: TextTheme(
              headline6: TextStyle(color: Colors.white),
            ),
            appBarTheme: AppBarTheme(
              titleTextStyle: TextStyle(
                color: darkPurple,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0.2,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
          routes: {
            AuthTypeScreen.routeName: (context) => AuthTypeScreen(),
            RegisterScreen.routeName: (context) => RegisterScreen(),
            OTPConfirmationScreen.routeName: (context) =>
                OTPConfirmationScreen(),
            CreateProfileScreen.routeName: (context) => CreateProfileScreen(),
            LoginScreen.routeName: (context) => LoginScreen(),
            HomePageScreen.routeName: (context) => HomePageScreen(),
            NavigationalAppScreen.routeName: (context) =>
                NavigationalAppScreen(),
            ChooseLangugageScreen.routeName: (context) =>
                ChooseLangugageScreen(),
            EstateListingScreen.routeName: (context) => EstateListingScreen(),
            EstateDetailScreen.routeName: (context) => EstateDetailScreen(),
            ChangeLanguage.routeName: (context) => ChangeLanguage(),
          },
        ),
      ),
    );
  }
}
