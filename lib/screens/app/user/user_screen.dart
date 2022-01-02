import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/user/balance_screen.dart';
import 'package:dachaturizm/screens/app/user/change_language.dart';
import 'package:dachaturizm/screens/app/user/edit_profile_screen.dart';
import 'package:dachaturizm/screens/app/user/my_announcements_screen.dart';
import 'package:dachaturizm/screens/app/user/wishlist_screen.dart';
import 'package:dachaturizm/screens/app/user_extra_details.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class UserPageScreen extends StatefulWidget {
  const UserPageScreen({Key? key}) : super(key: key);

  @override
  _UserPageScreenState createState() => _UserPageScreenState();
}

class _UserPageScreenState extends State<UserPageScreen> {
  bool _userLoading = false;
  bool _someChange = false;

  Future _refreshUser() async {
    setState(() {
      _userLoading = true;
    });
    await Provider.of<AuthProvider>(context, listen: false).getUserData();
    setState(() {
      _userLoading = false;
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
    Future.delayed(Duration.zero).then((_) {
      _refreshUser();
    });
    super.initState();
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
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserDetails(context, auth),
                SizedBox(height: 1.5 * defaultPadding),
                ColumnTitle("Mening profilim"),
                _buildProfileList(),
                SizedBox(height: 1.5 * defaultPadding),
                ColumnTitle("Sozlamalar"),
                _buildSettingsList(),
                // Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context, AuthProvider auth) {
    return Visibility(
      visible: !_userLoading,
      child: Container(
        decoration: BoxDecoration(
          color: disabledOrange,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: buildUserDetails(context, auth.user, true),
      ),
    );
  }

  Widget _buildProfileList() {
    bool userExists = Provider.of<AuthProvider>(context).user != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: !userExists,
          child: ProfileListItem(
            title: Locales.string(context, "login_profile"),
            iconData: Icons.person,
            callback: () {
              Navigator.of(context).pushNamed(LoginScreen.routeName);
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
            title: Locales.string(context, "balance"),
            iconData: Icons.account_balance_wallet_rounded,
            callback: () {
              callWithAuth(context, () {
                Navigator.of(context).pushNamed(BalanceScreen.routeName);
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
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    bool userExists = Provider.of<AuthProvider>(context).user != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: userExists,
          child: ProfileListItem(
            title: Locales.string(context, "edit_profile"),
            iconData: Icons.person_rounded,
            callback: () {
              callWithAuth(context, () {
                Navigator.of(context).pushNamed(EditProfileScreen.routeName);
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
              callWithAuth(context, () {
                Navigator.of(context).pushNamed(MyAnnouncements.routeName);
              });
            },
          ),
        ),
        ProfileListItem(
          title: Locales.string(context, "change_language"),
          iconData: Icons.language_rounded,
          callback: () async {
            final changeLang = ChangeLanguage();
            await _navigateTo(changeLang);
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

class ProfileListItem extends StatelessWidget {
  const ProfileListItem({
    Key? key,
    required this.title,
    required this.iconData,
    required this.callback,
  }) : super(key: key);

  final String title;
  final IconData iconData;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: defaultPadding / 3,
        horizontal: defaultPadding,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          callback();
        },
        child: Container(
          width: double.infinity,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: 30,
                height: 30,
                child: Icon(
                  iconData,
                  color: purplish,
                  size: 14,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                title,
                style: TextStyles.display1().copyWith(height: 1.5),
              ),
              Spacer(),
              Icon(Icons.keyboard_arrow_right_rounded)
            ],
          ),
        ),
      ),
    );
  }
}
