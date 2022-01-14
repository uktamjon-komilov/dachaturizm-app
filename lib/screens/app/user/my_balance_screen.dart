import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/parse_datetime.dart';
import 'package:dachaturizm/models/transaction_model.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/app/user/fill_balance_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MyBalanceScreen extends StatefulWidget {
  const MyBalanceScreen({Key? key}) : super(key: key);

  static const String routeName = "/my-balance";

  @override
  State<MyBalanceScreen> createState() => _MyBalanceScreenState();
}

class _MyBalanceScreenState extends State<MyBalanceScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  UserModel? _user;
  DateTime? _date;
  List<TransactionModel> _inTransactions = [];
  List<TransactionModel> _outTransactions = [];

  Future _refresh() async {
    await Future.wait([
      Provider.of<AuthProvider>(context, listen: false)
          .getUserDataWithoutNotifying()
          .then((user) => _user = user),
      Provider.of<AuthProvider>(context, listen: false)
          .getTransactions("in")
          .then((transactions) => _inTransactions = transactions),
      Provider.of<AuthProvider>(context, listen: false)
          .getTransactions("out")
          .then((transactions) => _outTransactions = transactions),
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      setState(() {
        _isLoading = true;
      });
      _refresh().then((_) {
        setState(() {
          _isLoading = false;
          _date = DateTime.now();
        });
      });
      ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildNavigationalAppBar(
          context,
          Locales.string(context, "my_balance"),
        ),
        bottomNavigationBar: buildBottomNavigation(context, () {
          Navigator.of(context).pop();
        }),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: EdgeInsets.fromLTRB(
                  defaultPadding,
                  defaultPadding,
                  defaultPadding,
                  0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardBlock(),
                      SizedBox(height: defaultPadding / 2),
                      Divider(
                        color: lightGrey,
                        thickness: 1,
                        height: 0,
                      ),
                      SizedBox(height: defaultPadding / 2),
                      _buildTransactionsList(
                        "Oxirgi to‘lov",
                        _inTransactions,
                      ),
                      SizedBox(height: defaultPadding / 2),
                      Divider(
                        color: lightGrey,
                        thickness: 1,
                        height: 0,
                      ),
                      SizedBox(height: defaultPadding / 2),
                      _buildTransactionsList(
                        "Oxirgi harajat",
                        _outTransactions,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCardBlock() {
    return Container(
      width: 100.w,
      child: Stack(
        children: [
          Image.asset(
            "assets/images/balance-card.png",
            fit: BoxFit.cover,
          ),
          Positioned(
            right: 28,
            bottom: 28,
            child: IconButton(
              onPressed: () async {
                await _refresh();
              },
              splashColor: normalOrange,
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: normalOrange,
                  size: 20,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_user!.balance} UZS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.33,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3 * defaultPadding),
                Text(
                  "Yangilandi: ${formatDateTime(_date)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(BalanceScreen.routeName,
                        arguments: {"user": _user});
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    primary: Colors.white,
                    onPrimary: normalOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Hisobni to‘ldirish",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
      String title, List<TransactionModel> transactions) {
    return transactions.length == 0
        ? Text("Sizda harajat mavjud emas")
        : Container(
            height: 25.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.display2().copyWith(letterSpacing: 0.3),
                ),
                SizedBox(height: defaultPadding / 2),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...transactions
                            .map(
                              (transaction) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      transaction.date,
                                      style: TextStyles.display8(),
                                    ),
                                    Text(
                                      "${transaction.amount} UZS",
                                      style: TextStyles.display8(),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
