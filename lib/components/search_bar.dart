import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    Key? key,
    required this.controller,
    required this.onSubmit,
    required this.onChange,
  }) : super(key: key);

  final TextEditingController controller;
  final Function onSubmit;
  final Function onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        onFieldSubmitted: (value) {
          onSubmit(value);
        },
        onChanged: (value) {
          onChange(value);
        },
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
