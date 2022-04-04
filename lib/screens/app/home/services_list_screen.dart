import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/service_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/repository/services_repository.dart';
import 'package:dachaturizm/screens/app/home/service_screen.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({Key? key}) : super(key: key);

  static String routeName = "/services-list";

  @override
  _ServicesListScreenState createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  List<Service> _services = [];

  _refresh(BuildContext context) async {
    Dio dio = Provider.of<AuthProvider>(context, listen: false).dio;
    ServicesRepository servicesRepository = ServicesRepository(dio: dio);
    List<Service> services = await servicesRepository.getServices();
    setState(() {
      _isLoading = false;
      _services = services;
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      await _refresh(context);
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavigationalAppBar(
        context,
        Locales.string(context, "services"),
      ),
      bottomNavigationBar: buildBottomNavigation(context, () {
        Navigator.of(context).pop();
      }),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _refresh(context);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    defaultPadding,
                    defaultPadding,
                    defaultPadding,
                    0,
                  ),
                  child: Column(
                    children: [
                      ..._services
                          .map((service) => _buildServiceItem(service))
                          .toList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildServiceItem(Service service) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          ServiceScreen.routeName,
          arguments: service,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 150,
              width: 100.w,
              child: Image.network(
                fixMediaUrl(service.photo),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.title,
            style: TextStyles.display1(),
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }
}
