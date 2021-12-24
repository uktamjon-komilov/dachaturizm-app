import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/user/change_language.dart';
import 'package:dachaturizm/screens/app/user/edit_profile_screen.dart';
import 'package:dachaturizm/screens/app/user/my_announcements_screen.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
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
  showLoginScreen() async {
    final loginScreen = LoginScreen();
    Map result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => loginScreen,
        settings: RouteSettings(
          arguments: {"relogin": true},
        ),
      ),
    ) as Map;
    Future.delayed(Duration.zero).then((_) {
      _refreshUser();
    });
  }

  Future callWithAuth([Function? callback]) async {
    final access = await Provider.of<AuthProvider>(context, listen: false)
        .getAccessToken();
    if (access != "") {
      if (callback != null) callback();
    } else {
      await showLoginScreen();
    }
  }

  Column _buildProfileList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileListItem(
          title: "my_estates",
          icon: Icon(Icons.notes),
          callback: () async {
            callWithAuth(() async {
              final myAnnouncements = MyAnnouncements();
              await _navigateTo(myAnnouncements);
            });
          },
        ),
        ProfileListItem(
          title: "my_favourites",
          icon: Icon(Icons.favorite_outline_rounded),
          callback: () {
            callWithAuth(() {
              Navigator.of(context).pushNamed(MyAnnouncements.routeName);
            });
          },
        ),
        ProfileListItem(
          title: "messages",
          icon: Icon(Icons.chat_bubble_outline_rounded),
          callback: () {
            callWithAuth(() {
              Navigator.of(context).pushNamed(MyAnnouncements.routeName);
            });
          },
        ),
        ProfileListItem(
          title: "edit_profile",
          icon: Icon(Icons.person_rounded),
          callback: () {
            callWithAuth(() {
              Navigator.of(context).pushNamed(EditProfileScreen.routeName);
            });
          },
        ),
        ProfileListItem(
          title: "change_password",
          icon: Icon(Icons.lock),
          callback: () {
            callWithAuth(() {
              Navigator.of(context).pushNamed(MyAnnouncements.routeName);
            });
          },
        ),
        ProfileListItem(
            title: "change_language",
            icon: Icon(Icons.language_rounded),
            callback: () async {
              final changeLang = ChangeLanguage();
              await _navigateTo(changeLang);
            }),
        Provider.of<AuthProvider>(context).user == null
            ? Container()
            : ProfileListItem(
                title: "profile_logout",
                icon: Icon(Icons.logout_rounded),
                callback: () {
                  callWithAuth(() async {
                    await showLoginScreen();
                  });
                },
              ),
      ],
    );
  }

  Widget _buildUserDetails(UserModel? user) {
    return user == null
        ? Container()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            width: double.infinity,
            // height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: defaultPadding),
                  child: CircleAvatar(
                    radius: 100.w * 0.10,
                    child: ClipOval(
                      child: (user.photo == null)
                          ? Image.asset(
                              "assets/images/user.jpg",
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              fixMediaUrl(user.photo),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "${user.firstName} ${user.lastName}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(user.phone), Text("ID: 0000000")],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LocaleText("your_balance"),
                            Text("${user.balance} UZS")
                          ],
                        ),
                        Wrap(
                          spacing: 10,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                callWithAuth(() async {
                                  final editProfile = EditProfileScreen();
                                  await _navigateTo(editProfile);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                primary: normalOrange,
                                side: BorderSide(
                                  color: normalOrange,
                                ),
                              ),
                              child: LocaleText(
                                "edit_profile",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                primary: normalOrange,
                                elevation: 0,
                              ),
                              child: LocaleText(
                                "fill_balance",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  bool _userLoading = false;
  bool _someChange = false;
  UserModel? _user;

  Future _refreshUser() async {
    setState(() {
      _userLoading = true;
    });
    Provider.of<AuthProvider>(context, listen: false)
        .getUserData()
        .then((value) {
      try {
        setState(() {
          _userLoading = false;
        });
        if (!value.containsKey("status")) {}
      } catch (e) {
        setState(() {
          _user = value;
          _userLoading = false;
        });
      }
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
                _userLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : _buildUserDetails(auth.user),
                Divider(),
                _buildProfileList(),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileListItem extends StatelessWidget {
  const ProfileListItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.callback,
  }) : super(key: key);

  final String title;
  final Icon icon;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: defaultPadding / 4, horizontal: defaultPadding / 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          callback();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: defaultPadding / 4, horizontal: defaultPadding / 4),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(8),
                child: icon,
              ),
              SizedBox(
                width: 10,
              ),
              LocaleText(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
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
