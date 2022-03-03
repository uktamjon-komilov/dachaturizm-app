import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/static_page_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class StaticPageScreen extends StatefulWidget {
  const StaticPageScreen({Key? key}) : super(key: key);

  static const String routeName = "/static-page";

  @override
  State<StaticPageScreen> createState() => _StaticPageScreenState();
}

class _StaticPageScreenState extends State<StaticPageScreen> {
  StaticPageModel? _page;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero).then((_) {
      final data = ModalRoute.of(context)!.settings.arguments;
      if (data == null) return;
      setState(() {
        _page = data as StaticPageModel;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavigationalAppBar(
        context,
        _page == null ? "" : _page!.title,
      ),
      bottomNavigationBar: buildBottomNavigation(context, () {
        Navigator.of(context).pop();
      }),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding,
          defaultPadding,
          0,
        ),
        child: SingleChildScrollView(
          child: Html(
            data: _page!.content,
          ),
        ),
      ),
    );
  }
}
