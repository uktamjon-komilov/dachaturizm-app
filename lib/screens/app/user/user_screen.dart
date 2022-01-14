import 'package:dachaturizm/components/profile_item.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/models/static_page_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/restartable_app.dart';
import 'package:dachaturizm/screens/app/user/change_language.dart';
import 'package:dachaturizm/screens/app/user/edit_profile_screen.dart';
import 'package:dachaturizm/screens/app/user/feedback_screen.dart';
import 'package:dachaturizm/screens/app/user/my_announcements_screen.dart';
import 'package:dachaturizm/screens/app/user/my_balance_screen.dart';
import 'package:dachaturizm/screens/app/user/renew_password_screen.dart';
import 'package:dachaturizm/screens/app/user/static_page_screen.dart';
import 'package:dachaturizm/screens/app/user/wishlist_screen.dart';
import 'package:dachaturizm/screens/app/user_extra_details.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

class UserPageScreen extends StatefulWidget {
  const UserPageScreen({Key? key}) : super(key: key);

  @override
  _UserPageScreenState createState() => _UserPageScreenState();
}

class _UserPageScreenState extends State<UserPageScreen> {
  bool _userLoading = false;
  bool _someChange = false;
  UserModel? _user;
  List<StaticPageModel> _staticPages = [];

  Future _refreshUser() async {
    setState(() {
      _userLoading = true;
    });
    Provider.of<AuthProvider>(context, listen: false)
        .getUserData()
        .then((user) {
      setState(() {
        _user = user;
      });
      Provider.of<EstateProvider>(context, listen: false)
          .getStaticPages()
          .then((value) {
        setState(() {
          _staticPages = value;
          _userLoading = false;
        });
      });
    });
  }

  _navigateTo(page) async {
    Map result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    ) as Map;
    if (result != null && result.containsKey("change")) {
      setState(() {
        _someChange = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      await _refreshUser();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_someChange) {
      _refreshUser().then((_) {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(4);
      });
      _someChange = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserDetails(
                  context, Provider.of<AuthProvider>(context).user),
              SizedBox(height: 1.5 * defaultPadding),
              ColumnTitle(Locales.string(context, "my_profile")),
              _buildProfileList(),
              SizedBox(height: 1.5 * defaultPadding),
              ColumnTitle(Locales.string(context, "settings")),
              _buildSettingsList(),
              SizedBox(height: 1.5 * defaultPadding),
              ColumnTitle("Boshqa sozlamalar"),
              ..._staticPages
                  .map((page) => SettingsItem(
                      title: page.title,
                      callback: () {
                        Navigator.of(context).pushNamed(
                            StaticPageScreen.routeName,
                            arguments: page);
                      }))
                  .toList(),
              SettingsItem(
                  title: Locales.string(context, "feedback"),
                  callback: () {
                    Navigator.of(context).pushNamed(FeedbackScreen.routeName);
                  }),
              // Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, UserModel? user) {
    return Visibility(
      visible: user != null,
      child: Container(
        decoration: BoxDecoration(
          color: disabledOrange,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: buildUserDetails(context, user, true),
      ),
    );
  }

  Widget _buildProfileList() {
    bool userExists =
        Provider.of<AuthProvider>(context, listen: false).userId != 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: !userExists,
          child: ProfileListItem(
            title: Locales.string(context, "login_profile"),
            iconData: Icons.person,
            callback: () async {
              final loginScreen = LoginScreen();
              await _navigateTo(loginScreen);
            },
          ),
        ),
        Visibility(
          visible: userExists,
          child: ProfileListItem(
            title: Locales.string(context, "my_estates"),
            iconData: Icons.description_rounded,
            callback: () async {
              callWithAuth(context, () async {
                final myAnnouncements = MyAnnouncements();
                await _navigateTo(myAnnouncements);
              });
            },
          ),
        ),
        Visibility(
          visible: userExists,
          child: ProfileListItem(
              title: Locales.string(context, "my_favourites"),
              iconData: Icons.favorite_outline_rounded,
              callback: () async {
                await callWithAuth(context, () async {
                  final wishlist = WishlistScreen();
                  await _navigateTo(wishlist);
                });
              }),
        ),
        Visibility(
          visible: userExists,
          child: ProfileListItem(
            title: Locales.string(context, "my_balance"),
            iconData: Icons.account_balance_wallet_rounded,
            callback: () {
              callWithAuth(context, () async {
                final myBalanceScreen = MyBalanceScreen();
                await _navigateTo(myBalanceScreen);
              });
            },
          ),
        ),
        Visibility(
          visible: userExists,
          child: ProfileListItem(
            title: Locales.string(context, "messages"),
            iconData: Icons.question_answer_rounded,
            callback: () {
              callWithAuth(context, () {
                Provider.of<NavigationScreenProvider>(context, listen: false)
                    .changePageIndex(3);
              });
            },
          ),
        ),
        Visibility(
          visible: userExists,
          child: ProfileListItem(
            title: Locales.string(context, "profile_logout"),
            iconData: Icons.logout_rounded,
            callback: () {
              callWithAuth(context, () async {
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();
                // Provider.of<AuthProvider>(context, listen: false).getUserData();
                // Navigator.of(context).pushNamed(LoginScreen.routeName);
                RestartWidget.restartApp(context);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    bool userExists =
        Provider.of<AuthProvider>(context, listen: false).user != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: userExists,
          child: ProfileListItem(
            title: Locales.string(context, "edit_profile"),
            iconData: Icons.person_rounded,
            callback: () {
              callWithAuth(context, () async {
                final editProfileScreen = EditProfileScreen();
                await _navigateTo(editProfileScreen);
              });
            },
          ),
        ),
        Visibility(
          visible: userExists,
          child: ProfileListItem(
            title: Locales.string(context, "change_password"),
            iconData: Icons.lock,
            callback: () {
              callWithAuth(context, () async {
                final renewPasswordScreen = RenewPasswordScreen();
                await _navigateTo(renewPasswordScreen);
              });
            },
          ),
        ),
        ProfileListItem(
          title: Locales.string(context, "change_language"),
          iconData: Icons.language_rounded,
          callback: () async {
            final changeLangScreen = ChangeLanguage();
            await _navigateTo(changeLangScreen);
          },
        ),
      ],
    );
  }
}

class ColumnTitle extends StatelessWidget {
  const ColumnTitle(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Text(
        text,
        style: TextStyles.display8(),
      ),
    );
  }
}
