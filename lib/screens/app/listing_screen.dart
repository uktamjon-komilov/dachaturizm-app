import 'package:flutter/material.dart';

class EstateListingScreen extends StatelessWidget {
  const EstateListingScreen({Key? key}) : super(key: key);

  static const routeName = "/estate-listing";

  @override
  Widget build(BuildContext context) {
    final int estateTypeId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(
        title: Text("Bo'limlar"),
      ),
      body: Container(
        padding: EdgeInsets.all(50),
        child: Text(estateTypeId.toString()),
      ),
    );
  }
}
