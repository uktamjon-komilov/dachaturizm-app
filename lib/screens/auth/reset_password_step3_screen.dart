import 'package:dachaturizm/components/fluid_big_button.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:dachaturizm/styles/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

class ResetPasswordStep3 extends StatefulWidget {
  const ResetPasswordStep3({Key? key}) : super(key: key);

  static const String routeName = "/reset-password3";

  @override
  _ResetPasswordStep3State createState() => _ResetPasswordStep3State();
}

class _ResetPasswordStep3State extends State<ResetPasswordStep3> {
  bool _hidePassword = true;
  bool _somethingWrong = false;

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  FocusNode _newPasswordFocusNode = FocusNode();
  FocusNode _confirmPasswordFocusNode = FocusNode();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Form(
            key: _form,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: defaultPadding * 1.5),
                    Text(
                      Locales.string(context, "new_password"),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: defaultPadding / 2),
                    Text(
                      Locales.string(context, "renew_profile_password"),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                        color: greyishLight,
                      ),
                    ),
                    SizedBox(height: 28),
                    _buildTextInput(
                      context,
                      hintText: "new_password_hint",
                      iconData: Icons.lock,
                      suffixIcon: Icons.remove_red_eye,
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                      obscureText: _hidePassword,
                      focusNode: _newPasswordFocusNode,
                      nextFocusNode: _newPasswordFocusNode,
                      controller: _newPasswordController,
                    ),
                    _buildTextInput(
                      context,
                      hintText: "new_confirm_password_hint",
                      iconData: Icons.lock,
                      suffixIcon: Icons.remove_red_eye,
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                      obscureText: _hidePassword,
                      focusNode: _confirmPasswordFocusNode,
                      controller: _confirmPasswordController,
                    ),
                    FluidBigButton(
                      text: Locales.string(context, "create_profile"),
                      onPress: () =>
                          resetPassword3(context, data["phone"], data["code"]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(
    BuildContext context, {
    String hintText = "",
    IconData iconData = Icons.person,
    bool obscureText = false,
    var suffixIcon = null,
    var onPressed = null,
    var focusNode = null,
    var nextFocusNode = null,
    var controller = null,
    var validator = null,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: TextFormField(
        controller: controller != null ? controller : null,
        focusNode: focusNode != null ? focusNode : null,
        decoration: InputDecoration(
          border: InputStyles.inputBorder(),
          focusedBorder: InputStyles.focusBorder(),
          enabledBorder: InputStyles.enabledBorder(),
          labelText: Locales.string(context, hintText),
          floatingLabelStyle: TextStyle(color: normalOrange),
          prefixIcon: Icon(iconData, color: greyishLight),
          hintText: Locales.string(context, hintText),
          hintStyle: TextStyle(color: greyishLight),
          suffixIcon: (suffixIcon != null && onPressed != null)
              ? IconButton(
                  icon: Icon(
                    suffixIcon as IconData,
                    color: greyishLight,
                  ),
                  onPressed: onPressed)
              : null,
        ),
        validator: (value) {
          if (value?.length == 0) {
            return Locales.string(context, hintText) +
                " " +
                Locales.string(context, "input_must_be");
          } else if (obscureText &&
              _newPasswordController.text != _confirmPasswordController.text) {
            return Locales.string(context, "passwords_must_match");
          } else if (obscureText && value!.length < 8) {
            return Locales.string(context, "password_min_length_amount");
          }
          return null;
        },
        onFieldSubmitted: (value) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        obscureText: obscureText,
      ),
    );
  }

  resetPassword3(BuildContext context, phone, code) {
    if (_form.currentState!.validate()) {
      setState(() {
        _somethingWrong = false;
      });
      Provider.of<AuthProvider>(context, listen: false)
          .resetPassword3(
        phone,
        code,
        _newPasswordController.text,
      )
          .then((value) {
        if (value["status"] as bool) {
          Navigator.of(context).popAndPushNamed(LoginScreen.routeName);
        } else {
          setState(() {
            _somethingWrong = true;
          });
        }
      });
    }
  }
}
