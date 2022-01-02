import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class UserEstatesScreen extends StatefulWidget {
  const UserEstatesScreen({Key? key}) : super(key: key);

  static const String routeName = "/user-estates";

  @override
  _UserEstatesScreenState createState() => _UserEstatesScreenState();
}

class _UserEstatesScreenState extends State<UserEstatesScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  List<EstateModel> _userEstates = [];
  UserModel? _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;

      Map<String, dynamic> modalData =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      if (modalData.containsKey("userId")) {
        int userId = modalData["userId"];
        Future.wait([
          Provider.of<EstateProvider>(context, listen: false)
              .getUserEstates(userId)
              .then((value) {
            _userEstates = value;
          }),
          Provider.of<AuthProvider>(context, listen: false)
              .getUser(userId)
              .then((value) {
            _user = value;
          }),
        ]).then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildNavigationalAppBar(
            context, Locales.string(context, "announcer")),
        bottomNavigationBar: buildBottomNavigation(context, () {
          Navigator.of(context)
              .popUntil(ModalRoute.withName(NavigationalAppScreen.routeName));
        }),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    buildUserDetails(_user),
                    Container(
                      width: 100.w,
                      padding: EdgeInsets.fromLTRB(
                        defaultPadding,
                        24,
                        defaultPadding,
                        defaultPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Locales.string(
                              context,
                              "announcers_other_ads",
                            ),
                            style: TextStyles.display2(),
                          ),
                          Visibility(
                            visible: _userEstates.length > 0,
                            child: Container(
                              width: 100.w,
                              padding: EdgeInsets.only(top: defaultPadding),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                runSpacing: 6,
                                children: [
                                  ..._userEstates
                                      .map((estate) =>
                                          EstateCard(estate: estate))
                                      .toList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildUserDetails(UserModel? user) {
    return Container(
      height: 150,
      padding: EdgeInsets.symmetric(horizontal: defaultPadding),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Container(
              width: 75,
              height: 75,
              child: user!.photo.length > 0
                  ? Image.network(
                      user.photo,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "assets/images/user.png",
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(width: defaultPadding),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user!.fullname,
                  style: TextStyles.display2().copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: defaultPadding * 3 / 4),
                _buildUserDetailPair(
                  Locales.string(context, "id_number"),
                  "# ${user.id}",
                ),
                SizedBox(height: defaultPadding / 2),
                _buildUserDetailPair(
                  "${Locales.string(context, 'phone')}:",
                  "+" + user.phone,
                ),
                SizedBox(height: defaultPadding / 2),
                _buildUserDetailPair(
                  Locales.string(context, "number_of_ads"),
                  user.adsCount.toString(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUserDetailPair(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyles.display8(),
        ),
        Text(
          value,
          style: TextStyles.display8(),
        ),
      ],
    );
  }
}
