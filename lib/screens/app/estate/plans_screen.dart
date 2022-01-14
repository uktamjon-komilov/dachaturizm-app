import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/call_with_auth.dart';
import 'package:dachaturizm/models/ads_plan.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/banner_provider.dart';
import 'package:dachaturizm/providers/category_provider.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/user/my_announcements_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({Key? key}) : super(key: key);

  static const String routeName = "/plans";

  @override
  _PlansScreenState createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  List<AdPlan> _plans = [];
  int _activePlanId = 0;
  UserModel? _user;
  dynamic _data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
        _isInit = false;
      });
      Future.wait([
        Provider.of<CurrencyProvider>(context, listen: false)
            .fetchAdPlans()
            .then((value) => _plans = value),
        Provider.of<AuthProvider>(context, listen: false)
            .getUserData()
            .then((user) => _user = user),
      ]).then((_) {
        try {
          Map<String, dynamic>? data = ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;
          if (data != null && data.containsKey("data")) {
            _data = data["data"];
          }
        } catch (e) {
          print(e);
        }
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double balance = _user == null ? 0.0 : _user!.balance;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: Text(
            Locales.string(context, "plans"),
            style: TextStyles.display2().copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        floatingActionButton: (_activePlanId != 0 && !_isLoading)
            ? Container(
                width: 100.w - 1.8 * defaultPadding,
                child: FluidBigButton(
                  text: Locales.string(context, "activate"),
                  onPress: () async {
                    if (_data == null) return null;
                    setState(() {
                      _isLoading = true;
                    });
                    await Provider.of<EstateProvider>(context, listen: false)
                        .createEstate(_data);
                    EstateModel? estate = await Provider.of<EstateProvider>(
                            context,
                            listen: false)
                        .getMyLastEstate();
                    if (estate == null) {
                      setState(() {
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(Locales.string(context,
                              "something_went_wrong_try_in_your_profile")),
                        ),
                      );
                    } else {
                      await Provider.of<EstateProvider>(context, listen: false)
                          .advertise(
                              _plans
                                  .firstWhere(
                                      (plan) => plan.id == _activePlanId)
                                  .slug,
                              estate.id);
                      Provider.of<NavigationScreenProvider>(context,
                              listen: false)
                          .changePageIndex(4);
                      Provider.of<EstateTypesProvider>(context, listen: false)
                          .getCategories()
                          .then(
                        (types) {
                          Future.wait([
                            Provider.of<BannerProvider>(context, listen: false)
                                .getBanners(types),
                            Provider.of<EstateProvider>(context, listen: false)
                                .getTopEstates(types),
                          ]);
                        },
                      );
                      callWithAuth(context, () {
                        Navigator.of(context)
                          ..pop()
                          ..pushNamed(MyAnnouncements.routeName);
                      });
                    }
                  },
                ),
              )
            : null,
        body: _isLoading
            ? Container(
                width: 100.w,
                height: 90.h,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Locales.string(context, "your_balance"),
                          style: TextStyles.display2(),
                        ),
                        Text(
                          "${balance} UZS",
                          style: TextStyles.display2()
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(height: defaultPadding * 3 / 4),
                    Text(
                      Locales.string(context, "you_can_change_plans_later_on"),
                      style: TextStyles.display8(),
                    ),
                    SizedBox(height: defaultPadding),
                    ..._plans.map((plan) {
                      return AdPlanItem(
                        title: plan.title,
                        description: plan.description,
                        price: plan.price,
                        active: _activePlanId == plan.id,
                        disabled: plan.price > balance,
                        onTap: () {
                          if (plan.price < balance) {
                            setState(() {
                              _activePlanId = plan.id;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  Locales.string(
                                      context, "you_dont_have_enough_money"),
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ],
                )),
              ),
      ),
    );
  }
}

class AdPlanItem extends StatelessWidget {
  const AdPlanItem({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    this.active,
    this.disabled,
    this.onTap,
  }) : super(key: key);

  final String title;
  final String? description;
  final double price;
  final bool? active;
  final bool? disabled;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Color textColor = disabledGrey;
    Color backgroundColor = inputGrey;
    if (active != null && active!) {
      textColor = Colors.white;
      backgroundColor = normalOrange;
    } else if (disabled != null && disabled!) {
      textColor = disabledLightGrey;
      backgroundColor = disabledOrange;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        height: 100,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: defaultPadding / 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${price} UZS",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            (disabled != null && disabled!)
                ? Row(
                    children: [
                      Text(
                        Locales.string(context, "you_dont_have_enough_money"),
                        style: TextStyles.display6().copyWith(
                          color: textColor,
                        ),
                      )
                    ],
                  )
                : Row(
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          color: textColor),
                      SizedBox(width: 10),
                      Text(
                        description ??
                            Locales.string(
                                context, "you_can_activate_this_plan"),
                        style: TextStyles.display6().copyWith(
                          color: textColor,
                        ),
                      )
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
