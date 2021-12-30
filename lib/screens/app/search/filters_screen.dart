import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/small_button.dart';
import 'package:dachaturizm/components/text_input.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SearchFilersScreen extends StatefulWidget {
  const SearchFilersScreen({Key? key}) : super(key: key);

  static String routeName = "/filters";

  @override
  _SearchFilersScreenState createState() => _SearchFilersScreenState();
}

class _SearchFilersScreenState extends State<SearchFilersScreen> {
  RangeValues _selectedRange = RangeValues(20, 100);
  bool _check = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildNavigationalAppBar(context, "Filters"),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              defaultPadding,
              defaultPadding,
              defaultPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tartiblash",
                  style: TextStyles.display5(),
                ),
                _buildOrderFilers(),
                SizedBox(height: defaultPadding / 2),
                Divider(height: 0),
                SizedBox(height: defaultPadding),
                Text(
                  "Manzilni kiriting",
                  style: TextStyles.display5(),
                ),
                SizedBox(height: 12),
                TextInput(hintText: "Manzil"),
                SizedBox(height: defaultPadding),
                Text(
                  "Narxni belgilang",
                  style: TextStyles.display5(),
                ),
                SizedBox(height: 12),
                Container(
                  width: 100.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50.w - 1.375 * defaultPadding,
                        child: TextInput(hintText: "10 000"),
                      ),
                      Container(
                        width: 50.w - 1.375 * defaultPadding,
                        child: TextInput(hintText: "300 000"),
                      ),
                    ],
                  ),
                ),
                RangeSlider(
                  min: 0,
                  max: 500,
                  divisions: 500,
                  values: _selectedRange,
                  onChanged: (RangeValues newRange) {
                    print(newRange);
                    setState(() {
                      _selectedRange = newRange;
                    });
                  },
                  activeColor: normalOrange,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          primary: true ? normalOrange : Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          minimumSize: Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                              topRight: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                          ),
                        ),
                        child: Text(
                          "UZS",
                          style: TextStyles.display1().copyWith(
                            letterSpacing: 0.3,
                            color: true ? inputGrey : greyishLight,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          primary: false ? normalOrange : inputGrey,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          minimumSize: Size(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                        ),
                        child: Text(
                          "USD",
                          style: TextStyles.display1().copyWith(
                            letterSpacing: 0.3,
                            color: false ? inputGrey : greyishLight,
                            height: 1.3,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: defaultPadding / 2),
                Divider(height: 0),
                SizedBox(height: defaultPadding),
                Text(
                  "Qo'shimcha filtrlar",
                  style: TextStyles.display5(),
                ),
                SizedBox(height: 12),
                Wrap(
                  children: [
                    ...List.generate(
                      50,
                      (index) => CustomCheckbox(
                        title: "Sauna",
                        value: _check,
                        onTap: () {
                          setState(() {
                            _check = !_check;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5 * defaultPadding),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          width: 100.w - 2 * defaultPadding,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              primary: normalOrange,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "Natijani ko‘rsatish",
              style: TextStyles.display6(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderFilers() {
    return Row(
      children: [
        SmallButton(
          "Avval yangisi",
          enabled: true,
          onPressed: () {},
        ),
        SmallButton(
          "Eng arzoni",
          enabled: false,
          onPressed: () {},
        ),
        SmallButton(
          "Eng qimmati",
          enabled: false,
          onPressed: () {},
        ),
      ],
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    Key? key,
    required this.title,
    required this.value,
    this.onTap,
    this.onChanged,
  }) : super(key: key);

  final String title;
  final bool value;
  final void Function()? onTap;
  final void Function(bool? value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SizedBox(
          width: 44.w,
          height: 20,
          child: Row(
            children: [
              Theme(
                data: ThemeData(
                  unselectedWidgetColor: inputGrey,
                ),
                child: Checkbox(
                  onChanged: onChanged ??
                      (value) {
                        onTap!();
                      },
                  value: value,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: normalOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(title)
            ],
          ),
        ),
      ),
    );
  }
}
