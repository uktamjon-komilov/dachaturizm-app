import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: Locales.string(context, "search"),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
