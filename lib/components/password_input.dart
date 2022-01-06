import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
    Key? key,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.hintText,
    this.validator,
  }) : super(key: key);

  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? Function(String?)? validator;

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _showPassword,
      validator: widget.validator,
      decoration: InputDecoration(
        border: InputStyles.inputBorder(),
        enabledBorder: InputStyles.enabledBorder(),
        focusedBorder: InputStyles.focusBorder(),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: greyishLight,
        ),
        hintText: widget.hintText ?? Locales.string(context, "password_hint"),
        hintStyle: TextStyle(color: greyishLight),
        suffixIcon: Container(
          margin: EdgeInsets.only(right: defaultPadding / 3),
          child: IconButton(
            icon: Icon(
              Icons.remove_red_eye_outlined,
              color: greyishLight,
            ),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
        ),
      ),
    );
  }
}
