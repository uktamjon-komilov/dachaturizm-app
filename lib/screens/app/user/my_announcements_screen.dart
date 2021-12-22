import 'package:flutter/material.dart';

class MyAnnouncements extends StatelessWidget {
  const MyAnnouncements({Key? key}) : super(key: key);

  static String routeName = "/my-announcements";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Text("My Announcements"),
        ),
      ),
    );
  }
}
