import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField(
      {Key? key,
      this.onFieldSubmitted,
      this.onChanged,
      this.validator,
      this.controller,
      this.focusNode})
      : super(key: key);

  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: InputStyles.inputBorder(),
        enabledBorder: InputStyles.enabledBorder(),
        focusedBorder: InputStyles.focusBorder(),
        prefixIcon:
            Icon(Icons.stay_current_portrait_rounded, color: greyishLight),
        hintText: Locales.string(context, "phone_number_hint"),
        hintStyle: TextStyle(color: greyishLight),
      ),
      inputFormatters: [MaskTextInputFormatter(mask: "+998 (##) ### ## ##")],
      keyboardType: TextInputType.number,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      validator: widget.validator,
      controller: widget.controller,
      focusNode: widget.focusNode,
    );
  }
}
