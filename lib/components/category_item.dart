import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    Key? key,
    required this.title,
    this.icon,
    this.onTap,
  }) : super(key: key);

  final String title;
  final String? icon;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: normalOrange,
              ),
              child: Container(
                height: 18.4,
                width: 16.66,
                child: icon == null
                    ? const Icon(Icons.all_inclusive_rounded,
                        color: Colors.white)
                    : SvgPicture.network(
                        icon as String,
                        fit: BoxFit.scaleDown,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyles.display4(),
          )
        ],
      ),
    );
  }
}
