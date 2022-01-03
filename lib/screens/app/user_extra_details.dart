import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/user_model.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

Widget buildUserDetails(BuildContext context, UserModel? user,
    [bool showBalance = false]) {
  return Container(
    height: 150,
    padding: EdgeInsets.symmetric(horizontal: defaultPadding),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: Container(
            width: 75,
            height: 75,
            child: user!.photo.length > 0
                ? Image.network(
                    user.photo,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/images/user.png",
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        SizedBox(width: defaultPadding),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullname,
                style: TextStyles.display2().copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: defaultPadding * 3 / 4),
              buildUserDetailPair(
                Locales.string(context, "id_number"),
                "# ${user.id}",
              ),
              SizedBox(height: defaultPadding / 2),
              buildUserDetailPair(
                "${Locales.string(context, 'phone')}:",
                "+" + user.phone,
              ),
              SizedBox(height: defaultPadding / 2),
              showBalance
                  ? buildUserDetailPair(
                      Locales.string(context, "my_account_balance"),
                      user.balance.toString(),
                    )
                  : buildUserDetailPair(
                      Locales.string(context, "number_of_ads"),
                      user.adsCount.toString(),
                    ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget buildUserDetailPair(String title, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyles.display8(),
      ),
      Text(
        value,
        style: TextStyles.display8(),
      ),
    ],
  );
}