import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/type_model.dart';
import 'package:dachaturizm/providers/type_provider.dart';
import 'package:dachaturizm/screens/app/listing_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:from_css_color/from_css_color.dart';
import 'package:provider/provider.dart';

class EstateTypeListView extends StatefulWidget {
  EstateTypeListView({Key? key}) : super(key: key);

  @override
  State<EstateTypeListView> createState() => _EstateTypeListViewState();
}

class _EstateTypeListViewState extends State<EstateTypeListView> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    final int screenWidth = queryData.size.width.toInt();
    final int screenHeight = queryData.size.height.toInt();

    final estateTypesData = Provider.of<EstateTypes>(context);
    final estateTypes = estateTypesData.items;

    return Container(
      height: (2 * screenHeight / 9),
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: defaultPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text1("Bo'limlar"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: (estateTypes
                    .map(
                      (estateType) => EstateTypeItem(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        item: estateType,
                      ),
                    )
                    .toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EstateTypeItem extends StatelessWidget {
  const EstateTypeItem({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.item,
  }) : super(key: key);

  final int screenWidth;
  final int screenHeight;
  final TypeModel item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(EstateListingScreen.routeName, arguments: item.id);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          // side: BorderSide(width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              // side: BorderSide(width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Container(
            width: screenWidth / 4,
            height: screenHeight / 7,
            padding: EdgeInsets.all(2 * defaultPadding / 3),
            decoration:
                BoxDecoration(color: fromCssColor(item.backgroundColor)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  item.icon,
                  height: 70,
                  fit: BoxFit.fill,
                ),
                SizedBox(
                  height: 10,
                ),
                Flexible(
                  child: Text(
                    item.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: fromCssColor(item.foregroundColor),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
