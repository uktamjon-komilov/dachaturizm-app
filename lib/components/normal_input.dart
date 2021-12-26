import 'package:dachaturizm/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class NormalTextInput extends StatelessWidget {
  const NormalTextInput({
    GlobalKey? key,
    this.hintText = "",
    this.maxLines = 1,
    this.maxLength = 255,
    required this.onChanged,
    required this.controller,
    this.focusNode,
    required this.onSubmitted,
    ScrollController? scrollController,
    this.isPhone = false,
    this.isPrice = false,
    this.validation = false,
  }) : super(key: key);

  final String hintText;
  final int maxLines;
  final int maxLength;
  final TextEditingController controller;
  final focusNode;
  final Function onChanged;
  final Function onSubmitted;
  final bool isPhone;
  final bool isPrice;
  final bool validation;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      keyboardType:
          (isPhone || isPrice) ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        isPhone
            ? MaskTextInputFormatter(mask: "+998 ## ### ## ##")
            : LengthLimitingTextInputFormatter(255),
      ],
      onChanged: (value) {
        // onChanged(value);
      },
      onFieldSubmitted: (value) {
        onSubmitted(value);
      },
      validator: (value) {
        if (!validation) return null;
        if (value != null && value.length < 13 && isPhone) {
          return Locales.string(context, "Please, enter a valid phone number");
        } else if (isPhone) {
          return null;
        }
        if (value != null && value.length == 0 && isPrice) {
          return Locales.string(context, "Please, enter a valid price");
        } else if (isPrice) {
          return null;
        }
        if (value != null && value.length < (maxLines > 1 ? 50 : 20)) {
          return Locales.string(context, "must_be_at_least_20_chars");
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: normalGrey.withAlpha(150)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: normalOrange)),
        contentPadding: EdgeInsets.all(defaultPadding / 2),
      ),
      style: TextStyle(fontSize: 18),
    );
  }
}
