import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future callWithAuth(context, [Function? callback]) async {
  final access =
      await Provider.of<AuthProvider>(context, listen: false).getAccessToken();
  final refresh =
      await Provider.of<AuthProvider>(context, listen: false).getRefreshToken();
  if (access != "" && refresh != "") {
    if (callback != null) callback();
  } else {
    Navigator.of(context).pushNamed(LoginScreen.routeName);
  }
}
