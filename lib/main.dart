import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/banner_provider.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/facility_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/providers/region_provider.dart';
import 'package:dachaturizm/restartable_app.dart';
import 'package:dachaturizm/screens/app/chat/chat_list_screen.dart';
import 'package:dachaturizm/screens/app/chat/chat_screen.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:dachaturizm/screens/app/estate/location_picker_screen.dart';
import 'package:dachaturizm/screens/app/home/home_screen.dart';
import 'package:dachaturizm/screens/app/home/listing_screen.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/app/search/filters_screen.dart';
import 'package:dachaturizm/screens/app/user/balance_screen.dart';
import 'package:dachaturizm/screens/app/user/change_language.dart';
import 'package:dachaturizm/screens/app/user/edit_profile_screen.dart';
import 'package:dachaturizm/screens/app/user/my_announcements_screen.dart';
import 'package:dachaturizm/screens/app/user/wishlist_screen.dart';
import 'package:dachaturizm/screens/auth/auth_type_screen.dart';
import 'package:dachaturizm/screens/auth/create_profile_screen.dart';
import 'package:dachaturizm/screens/auth/otp_confirmation_screen.dart';
import 'package:dachaturizm/screens/auth/register_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/screens/loading/choose_language_screen.dart';
import 'package:dachaturizm/screens/splash_screen.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'providers/type_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(["en", "uz", "ru"]);
  runApp(RestartWidget(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: 100,
        retryDelays: List.generate(
          100,
          (index) => Duration(seconds: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: AuthProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: BannerProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: EstateTypesProvider(dio: dio),
          ),
          ChangeNotifierProxyProvider<AuthProvider, EstateProvider>(
            create: (context) =>
                EstateProvider(dio: dio, auth: AuthProvider(dio: dio)),
            update: (context, auth, _) => EstateProvider(dio: dio, auth: auth),
          ),
          ChangeNotifierProxyProvider<AuthProvider, NavigationScreenProvider>(
            create: (context) =>
                NavigationScreenProvider(auth: AuthProvider(dio: dio)),
            update: (context, auth, _) => NavigationScreenProvider(auth: auth),
          ),
          ChangeNotifierProvider.value(
            value: FacilityProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: CurrencyProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: RegionProvider(),
          ),
        ],
        child: Sizer(builder: (context, orientation, deviceType) {
          Provider.of<AuthProvider>(context, listen: false).refresh_token();
          return MaterialApp(
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
              LocationPickerScreen.routeName: (context) =>
                  LocationPickerScreen(),
              LoginScreen.routeName: (context) => LoginScreen(),
              HomePageScreen.routeName: (context) => HomePageScreen(),
              NavigationalAppScreen.routeName: (context) =>
                  NavigationalAppScreen(),
              ChooseLangugageScreen.routeName: (context) =>
                  ChooseLangugageScreen(),
              EstateListingScreen.routeName: (context) => EstateListingScreen(),
              SearchFilersScreen.routeName: (context) => SearchFilersScreen(),
              EstateDetailScreen.routeName: (context) => EstateDetailScreen(),
              EditProfileScreen.routeName: (context) => EditProfileScreen(),
              ChatListScreen.routeName: (context) => ChatListScreen(),
              ChatScreen.routeName: (context) => ChatScreen(),
              MyAnnouncements.routeName: (context) => MyAnnouncements(),
              WishlistScreen.routeName: (context) => WishlistScreen(),
              BalanceScreen.routeName: (context) => BalanceScreen(),
              ChangeLanguage.routeName: (context) => ChangeLanguage(),
            },
          );
        }),
      ),
    );
  }
}
