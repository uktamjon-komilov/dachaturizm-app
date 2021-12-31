import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/input.dart';
import 'package:flutter/material.dart';
import 'package:dachaturizm/styles/text_styles.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    Key? key,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
  }) : super(key: key);

  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyles.display5(),
      decoration: InputDecoration(
        border: InputStyles.inputBorder(),
        enabledBorder: InputStyles.enabledBorder(),
        focusedBorder: InputStyles.focusBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
        hintText: hintText ?? "",
        hintStyle: TextStyles.display5().copyWith(color: greyishLight),
      ),
      textAlignVertical: TextAlignVertical.center,
      maxLines: 1,
    );
  }
}
