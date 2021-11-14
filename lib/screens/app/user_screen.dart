import "package:flutter/material.dart";

class UserPageScreen extends StatefulWidget {
  const UserPageScreen({Key? key}) : super(key: key);

  @override
  _UserPageScreenState createState() => _UserPageScreenState();
}

class _UserPageScreenState extends State<UserPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("User Page"),
      ),
    );
  }
}
