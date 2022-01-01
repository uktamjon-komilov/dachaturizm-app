import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/screens/app/search/filters_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_locales/flutter_locales.dart';
import 'package:sizer/sizer.dart';

class SearchBarWithFilter extends StatelessWidget {
  const SearchBarWithFilter({
    Key? key,
    required this.controller,
    required this.onSubmit,
    this.onChange,
    this.onFilterTap,
    this.autofocus = false,
    this.focusNode,
    this.onFilterCallback,
  }) : super(key: key);

  final TextEditingController controller;
  final Function onSubmit;
  final Function? onChange;
  final Function? onFilterCallback;
  final Function? onFilterTap;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 100.w - 97,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode ?? null,
            autofocus: autofocus,
            onFieldSubmitted: (value) {
              onSubmit(value);
            },
            onChanged: (value) {
              if (onChange != null) {
                onChange!(value);
              }
            },
            decoration: InputDecoration(
              hintText: Locales.string(context, "search"),
              hintStyle: TextStyle(
                color: Color(0xFFC4C5C4),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  onSubmit(controller.text);
                },
                child: Icon(
                  Icons.search_rounded,
                  color: Color(0xFFC4C5C4),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Color(0xFFF17C31).withOpacity(0.15),
              blurRadius: 25,
              offset: Offset(0, 4),
            ),
          ]),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(SearchFilersScreen.routeName,
                  arguments: {"onFilterCallback": onFilterCallback});
              if (onFilterTap == null) {
                onFilterTap!();
              }
            },
            child: Icon(Icons.tune, color: Colors.white),
            style: TextButton.styleFrom(
              backgroundColor: normalOrange,
              minimumSize: Size(45, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        )
      ],
    );
  }
}
