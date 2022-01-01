import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';

AppBar buildNavigationalAppBar(BuildContext context, String title,
    [Function? refreshNavigationCallback, List<Widget>? actions]) {
  return AppBar(
    leading: IconButton(
      onPressed: () {
        if (refreshNavigationCallback != null) {
          refreshNavigationCallback();
        }
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.chevron_left_rounded,
        size: 24,
        color: greyishLight,
      ),
    ),
    title: Text(
      title,
      style: TextStyles.display2().copyWith(fontWeight: FontWeight.w700),
    ),
    actions: actions,
  );
}
