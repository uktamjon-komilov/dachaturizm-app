import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';

class ProfileListItem extends StatelessWidget {
  const ProfileListItem({
    Key? key,
    required this.title,
    required this.iconData,
    required this.callback,
  }) : super(key: key);

  final String title;
  final IconData iconData;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: defaultPadding / 3,
        horizontal: defaultPadding / 1.5,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          callback();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: 30,
                height: 30,
                child: Icon(
                  iconData,
                  color: purplish,
                  size: 14,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                title,
                style: TextStyles.display1().copyWith(height: 1.5),
              ),
              const Spacer(),
              Icon(Icons.keyboard_arrow_right_rounded)
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    Key? key,
    required this.title,
    required this.callback,
  }) : super(key: key);

  final String title;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: defaultPadding / 3,
        horizontal: defaultPadding / 1.5,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          callback();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            10,
            3,
            10,
            6,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyles.display1(),
              ),
              Spacer(),
              Icon(Icons.keyboard_arrow_right_rounded)
            ],
          ),
        ),
      ),
    );
  }
}
