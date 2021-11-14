import "package:flutter/material.dart";

class SearchBar extends StatelessWidget {
  const SearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: "Qidirish",
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          suffixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
