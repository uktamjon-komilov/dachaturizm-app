import "package:flutter/material.dart";

class EstateCreationPageScreen extends StatefulWidget {
  const EstateCreationPageScreen({Key? key}) : super(key: key);

  @override
  _EstateCreationPageScreenState createState() =>
      _EstateCreationPageScreenState();
}

class _EstateCreationPageScreenState extends State<EstateCreationPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Estate Creation Page"),
      ),
    );
  }
}
