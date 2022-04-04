import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/screens/app/navigational_app_screen.dart';
import 'package:dachaturizm/screens/app/user_extra_details.dart';
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
    return Scaffold(
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
                  buildUserDetails(context, _user),
                  Container(
                    width: 100.w,
                    padding: const EdgeInsets.fromLTRB(
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
                            padding: const EdgeInsets.only(top: defaultPadding),
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              runSpacing: 6,
                              children: [
                                ..._userEstates
                                    .map((estate) => EstateCard(estate: estate))
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
    );
  }
}
