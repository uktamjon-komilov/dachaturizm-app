import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  static String routeName = "/balance";

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _somethingWrong = false;
  double _balance = 0.0;

  GlobalKey<FormState> _form = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  FocusNode _amountFocusNode = FocusNode();

  final CurrencyTextInputFormatter _formatter =
      CurrencyTextInputFormatter(symbol: "", decimalDigits: 0);

  _getPaymentUrl(String type, double amount) async {
    if (_form.currentState!.validate()) {
      dynamic userId =
          await Provider.of<AuthProvider>(context, listen: false).getUserId();
      if (userId == null || userId == "") {
        Navigator.of(context)
          ..pop()
          ..pushNamed(LoginScreen.routeName);
      }
      String url = await Provider.of<CurrencyProvider>(context, listen: false)
          .getPaymentLinks(type, int.parse(userId.toString()), amount);
      if (url == "") {
        setState(() {
          _somethingWrong = true;
        });
        return "";
      }
      return url;
    }
  }

  _refreshBalance() async {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<AuthProvider>(context, listen: false)
          .getUserData()
          .then((user) {
        try {
          if (user.containsKey("status")) {}
        } catch (e) {
          setState(() {
            _balance = user.balance;
            _isLoading = false;
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_somethingWrong) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Something went wrong!")));
      setState(() {
        _somethingWrong = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // if (state == AppLifecycleState.resumed) {
    //   await _refreshBalance();
    // }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    Future.delayed(Duration.zero).then((_) async {
      await _refreshBalance();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .changePageIndex(4);
        return true;
      },
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
          title: Text("Balans"),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: EdgeInsets.all(defaultPadding),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text1("Balans: ${_balance} so'm"),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _amountController,
                        focusNode: _amountFocusNode,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_formatter],
                        decoration: InputDecoration(
                          hintText: "Masalan, 150 000 so'm",
                          hintStyle:
                              TextStyle(color: normalGrey.withAlpha(150)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: normalOrange)),
                          contentPadding: EdgeInsets.all(defaultPadding / 2),
                        ),
                        style: TextStyle(fontSize: 18),
                        onFieldSubmitted: (value) {},
                        onChanged: (value) {
                          _form.currentState!.validate();
                        },
                        validator: (value) {
                          int? temp = int.tryParse(value
                              .toString()
                              .replaceAll(",", "")
                              .replaceAll(".", ""));
                          if (temp != null && temp < 5000) {
                            return "Minimal to'lov summasi 5000 so'm";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: defaultPadding),
                      Wrap(
                        children: [
                          _buildPaymentButton("payme"),
                          _buildPaymentButton("click"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      )),
    );
  }

  Widget _buildPaymentButton(String type) {
    return GestureDetector(
      onTap: () async {
        double? amount = double.tryParse(_amountController.text
            .toString()
            .replaceAll(",", "")
            .replaceAll(".", ""));
        if (amount == null) {
          setState(() {
            _somethingWrong = true;
          });
        } else {
          String url = await _getPaymentUrl(type, amount);
          print(url);
          if (await UrlLauncher.canLaunch(url)) {
            UrlLauncher.launch(url);
          } else {
            setState(() {
              _somethingWrong = true;
            });
          }
        }
      },
      child: Container(
        width: 50.w - defaultPadding,
        padding: EdgeInsets.symmetric(vertical: defaultPadding),
        child: Center(
          child: Image.asset("assets/images/${type}.png"),
        ),
      ),
    );
  }
}
