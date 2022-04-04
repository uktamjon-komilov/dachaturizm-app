import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/banner_provider.dart';
import 'package:dachaturizm/providers/create_estate_provider.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/facility_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/providers/region_provider.dart';
import 'package:dachaturizm/providers/static_pages_provider.dart';
import 'package:dachaturizm/push_nofitication_service.dart';
import 'package:dachaturizm/restartable_app.dart';
import 'package:dachaturizm/screens/app/chat/chat_list_screen.dart';
import 'package:dachaturizm/screens/app/chat/chat_screen.dart';
import 'package:dachaturizm/screens/app/estate/create_estate_screen.dart';
import 'package:dachaturizm/screens/app/estate/estate_detail_screen.dart';
import 'package:dachaturizm/screens/app/estate/location_picker_screen.dart';
import 'package:dachaturizm/screens/app/estate/plans_screen.dart';
import 'package:dachaturizm/screens/app/estate/user_estates_screen.dart';
import 'package:dachaturizm/screens/app/home/home_screen.dart';
import 'package:dachaturizm/screens/app/home/listing_screen.dart';
import 'package:dachaturizm/screens/app/home/service_screen.dart';
import 'package:dachaturizm/screens/app/home/services_list_screen.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/app/search/filters_screen.dart';
import 'package:dachaturizm/screens/app/user/feedback_screen.dart';
import 'package:dachaturizm/screens/app/user/fill_balance_screen.dart';
import 'package:dachaturizm/screens/app/user/change_language.dart';
import 'package:dachaturizm/screens/app/user/edit_profile_screen.dart';
import 'package:dachaturizm/screens/app/user/my_announcements_screen.dart';
import 'package:dachaturizm/screens/app/user/my_balance_screen.dart';
import 'package:dachaturizm/screens/app/user/renew_password_screen.dart';
import 'package:dachaturizm/screens/app/user/static_page_screen.dart';
import 'package:dachaturizm/screens/app/user/wishlist_screen.dart';
import 'package:dachaturizm/screens/auth/auth_type_screen.dart';
import 'package:dachaturizm/screens/auth/create_profile_screen.dart';
import 'package:dachaturizm/screens/auth/otp_confirmation_screen.dart';
import 'package:dachaturizm/screens/auth/register_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/screens/auth/reset_password_step1_screen.dart';
import 'package:dachaturizm/screens/auth/reset_password_step2_screen.dart';
import 'package:dachaturizm/screens/auth/reset_password_step3_screen.dart';
import 'package:dachaturizm/screens/loading/choose_language_screen.dart';
import 'package:dachaturizm/screens/splash_screen.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'providers/category_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Firebase.initializeApp();

  NotificationService notificationService = NotificationService();

  await Locales.init(["en", "uz", "ru"]);
  Dio dio = Dio();

  final auth = AuthProvider(dio: dio);

  runApp(
    RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: BannerProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: EstateTypesProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: FacilityProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: CurrencyProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: StaticPagesProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: RegionProvider(dio: dio),
          ),
          ChangeNotifierProvider.value(
            value: auth,
          ),
          ChangeNotifierProvider.value(
            value: CreateEstateProvider(dio: dio, auth: auth),
          ),
          ChangeNotifierProxyProvider<AuthProvider, EstateProvider>(
            create: (context) => EstateProvider(dio: dio, auth: auth),
            update: (context, _a, _) => EstateProvider(dio: dio, auth: auth),
          ),
          ChangeNotifierProxyProvider<AuthProvider, NavigationScreenProvider>(
            create: (context) => NavigationScreenProvider(
              auth: AuthProvider(dio: dio),
            ),
            update: (context, auth, _) => NavigationScreenProvider(auth: auth),
          ),
        ],
        child: MyApp(
          dio: dio,
          notificationService: notificationService,
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.dio, required this.notificationService})
      : super(key: key);

  final Dio dio;
  final NotificationService notificationService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    widget.dio.interceptors.add(
      RetryInterceptor(
        dio: widget.dio,
        retries: 100,
        retryDelays: List.generate(
          100,
          (index) => Duration(seconds: index * 1),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      widget.notificationService.registerNotification(context);
      Provider.of<AuthProvider>(context, listen: false)
          .getUserData()
          .then((data) {
        print(data);
        Provider.of<RegionProvider>(context, listen: false).getAndSetRegions();
        Provider.of<StaticPagesProvider>(context, listen: false)
            .getStaticPages();
        Provider.of<FacilityProvider>(context, listen: false).fetchAll();
        Provider.of<CurrencyProvider>(context, listen: false).getCurrencies();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => Sizer(builder: (context, orientation, deviceType) {
        Provider.of<AuthProvider>(context, listen: false).refresh_token();
        return MaterialApp(
          title: "DachaTurizm",
          localizationsDelegates: Locales.delegates,
          supportedLocales: Locales.supportedLocales,
          locale: locale,
          theme: ThemeData(
            fontFamily: GoogleFonts.inter().fontFamily,
            primarySwatch: Colors.grey,
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: darkPurple,
                  displayColor: darkPurple,
                  fontFamily: GoogleFonts.inter().fontFamily,
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
            backgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
          ),
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
          routes: {
            AuthTypeScreen.routeName: (context) => AuthTypeScreen(),
            RegisterScreen.routeName: (context) => RegisterScreen(),
            OTPConfirmationScreen.routeName: (context) =>
                OTPConfirmationScreen(),
            CreateProfileScreen.routeName: (context) => CreateProfileScreen(),
            LocationPickerScreen.routeName: (context) => LocationPickerScreen(),
            LoginScreen.routeName: (context) => LoginScreen(),
            ResetPasswordStep1.routeName: (context) => ResetPasswordStep1(),
            ResetPasswordStep2.routeName: (context) => ResetPasswordStep2(),
            ResetPasswordStep3.routeName: (context) => ResetPasswordStep3(),
            HomePageScreen.routeName: (context) => HomePageScreen(),
            NavigationalAppScreen.routeName: (context) =>
                NavigationalAppScreen(),
            ChooseLangugageScreen.routeName: (context) =>
                ChooseLangugageScreen(),
            EstateListingScreen.routeName: (context) => EstateListingScreen(),
            EstateCreationPageScreen.routeName: (context) =>
                EstateCreationPageScreen(),
            PlansScreen.routeName: (context) => PlansScreen(),
            ServicesListScreen.routeName: (context) => ServicesListScreen(),
            ServiceScreen.routeName: (context) => ServiceScreen(),
            SearchFilersScreen.routeName: (context) => SearchFilersScreen(),
            EstateDetailScreen.routeName: (context) => EstateDetailScreen(),
            UserEstatesScreen.routeName: (context) => UserEstatesScreen(),
            EditProfileScreen.routeName: (context) => EditProfileScreen(),
            ChatListScreen.routeName: (context) => ChatListScreen(),
            ChatScreen.routeName: (context) => ChatScreen(),
            MyAnnouncements.routeName: (context) => MyAnnouncements(),
            WishlistScreen.routeName: (context) => WishlistScreen(),
            MyBalanceScreen.routeName: (context) => MyBalanceScreen(),
            BalanceScreen.routeName: (context) => BalanceScreen(),
            RenewPasswordScreen.routeName: (context) => RenewPasswordScreen(),
            ChangeLanguage.routeName: (context) => ChangeLanguage(),
            StaticPageScreen.routeName: (context) => StaticPageScreen(),
            FeedbackScreen.routeName: (context) => FeedbackScreen(),
          },
        );
      }),
    );
  }
}
