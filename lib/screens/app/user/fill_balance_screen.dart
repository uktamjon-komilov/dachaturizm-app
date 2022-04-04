import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/providers/currency_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/styles/input.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
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
  String _activePayment = defaultPaymentMethod;

  GlobalKey<FormState> _form = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();

  _getPaymentUrl(double amount) async {
    if (_form.currentState!.validate()) {
      dynamic userId =
          await Provider.of<AuthProvider>(context, listen: false).getUserId();
      if (userId == null || userId == "") {
        Navigator.of(context)
          ..pop()
          ..pushNamed(LoginScreen.routeName);
      }
      String url = await Provider.of<CurrencyProvider>(context, listen: false)
          .getPaymentLinks(
              _activePayment, int.parse(userId.toString()), amount);
      if (url == "") {
        return "";
      }
      return url;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavigationalAppBar(
          context, Locales.string(context, "payment"), () {
        Navigator.of(context).pop();
      }),
      floatingActionButton: Container(
        width: 100.w - 1.8 * defaultPadding,
        child: FluidBigButton(
          text: Locales.string(context, "ready"),
          onPress: () async {
            double? amount = double.tryParse(_amountController.text
                .toString()
                .replaceAll(",", "")
                .replaceAll(".", ""));
            if (amount != null) {
              String? url = await _getPaymentUrl(amount);
              if (url.runtimeType.toString() == "String" &&
                  await UrlLauncher.canLaunch(url as String)) {
                UrlLauncher.launch(url);
              }
            }
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding,
          defaultPadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(Locales.string(context, "amount")),
            const SizedBox(height: defaultPadding * 3 / 4),
            _buildInputField(),
            Text(
              Locales.string(context, "enter_payment_amount"),
              style: const TextStyle(
                fontSize: 10,
                height: 1.5,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
                color: greyishLight,
              ),
            ),
            const SizedBox(height: 1.5 * defaultPadding),
            CustomText(Locales.string(context, "payment_method")),
            const SizedBox(height: defaultPadding * 3 / 4),
            ...paymentMethods
                .map((method) => PaymentButton(
                      title: method,
                      active: _activePayment == method,
                      onPressed: () {
                        setState(() {
                          _activePayment = method;
                        });
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Form(
      key: _form,
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        maxLines: 1,
        decoration: InputDecoration(
          border: InputStyles.inputBorder(),
          enabledBorder: InputStyles.enabledBorder(),
          focusedBorder: InputStyles.focusBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: defaultPadding / 2,
            vertical: 0,
          ),
          hintText: Locales.string(context, "enter_payment_amount"),
          hintStyle: const TextStyle(
            fontSize: 13,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w500,
            color: greyishLight,
          ),
        ),
        validator: (value) {
          if (value == null) {
            return Locales.string(context, "payment_amount_cannot_be_empty");
          } else if (double.parse(value) < 5000) {
            return Locales.string(
                context, "payment_amount_must_be_greater_than_5000");
          }
          return null;
        },
      ),
    );
  }
}

class PaymentButton extends StatelessWidget {
  const PaymentButton({
    Key? key,
    required this.title,
    required this.active,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final bool active;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 100.w,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          vertical: 19,
          horizontal: defaultPadding,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: active ? normalOrange : inputGrey,
            )),
        child: Row(
          children: [
            Container(
              width: 42,
              child: Image.asset(
                "assets/images/${title}.png",
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: defaultPadding),
            Text(
              title.substring(0, 1).toUpperCase() +
                  title.substring(1, title.length),
              style: TextStyle(
                color: active ? normalOrange : greyishLight,
                fontSize: 13,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  const CustomText(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyles.display2().copyWith(letterSpacing: 0.3),
    );
  }
}
