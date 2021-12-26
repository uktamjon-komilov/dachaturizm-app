import 'package:dachaturizm/components/card.dart';
import 'package:dachaturizm/components/text1.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/providers/estate_provider.dart';
import 'package:dachaturizm/providers/navigation_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  static String routeName = "/wishlist";

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = false;
  List<EstateModel> _estates = [];

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<EstateProvider>(context, listen: false)
          .myWishlist()
          .then((value) {
        setState(() {
          _estates = value;
          _isLoading = false;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Provider.of<NavigationScreenProvider>(context, listen: false)
            .refreshHomePage = true;
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              Locales.string(context, "wishlist"),
            ),
          ),
          body: Container(
            padding: EdgeInsets.all(defaultPadding),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  _isLoading
                      ? Container(
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ((_estates.length == 0)
                          ? Container(
                              height: 100,
                              child: Center(
                                child: Text(
                                  Locales.string(context, "no_wishlist_items"),
                                ),
                              ),
                            )
                          : Wrap(
                              children: [
                                ..._estates
                                    .map((estate) => EstateCard(estate: estate))
                                    .toList(),
                              ],
                            )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
