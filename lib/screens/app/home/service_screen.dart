import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/service_model.dart';
import 'package:dachaturizm/providers/auth_provider.dart';
import 'package:dachaturizm/repository/services_repository.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  static String routeName = "/service";

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  Service? _service;
  List<ServiceItem> _items = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      Service data = ModalRoute.of(context)?.settings.arguments as Service;
      Dio dio = Provider.of<AuthProvider>(context, listen: false).dio;
      ServicesRepository servicesRepository = ServicesRepository(dio: dio);
      List<ServiceItem> items =
          await servicesRepository.getServiceItems(data.id);
      setState(() {
        _service = data;
        _items = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildNavigationalAppBar(
          context, _service == null ? "" : _service!.title),
      bottomNavigationBar: buildBottomNavigation(context, () {
        Navigator.of(context)
          ..pop()
          ..pop();
      }),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 150,
                        width: 100.w,
                        child: Image.network(
                          fixMediaUrl(_service!.photo),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _service!.content,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.92,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Visibility(
                      visible: (_service!.email != null ||
                          _service!.phone1 != null ||
                          _service!.phone2 != null),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: defaultPadding),
                          Text(
                            Locales.string(context, "for_contact"),
                            style: TextStyles.display1(),
                          ),
                          const SizedBox(height: defaultPadding),
                          _buildContactPhones(),
                          const SizedBox(height: defaultPadding),
                          _buildContactEmail(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        ..._items
                            .map(
                              (item) => Container(
                                width: 100.w,
                                height: 80,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                item.title,
                                                maxLines: 2,
                                                style: TextStyles.display2()
                                                    .copyWith(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Text(item.phone)
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          String phone = item.phone;
                                          if (!phone.startsWith("+")) {
                                            phone = "+" + phone;
                                          }
                                          UrlLauncher.launch("tel://${phone}");
                                        },
                                        icon: const Icon(Icons.phone),
                                      )
                                    ]),
                              ),
                            )
                            .toList()
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContactEmail() {
    return Visibility(
      visible: _service!.email != null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: darkPurple,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.email_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: defaultPadding),
          Text(
            _service!.email.toString(),
            style: TextStyles.display1().copyWith(height: 1.21),
          ),
        ],
      ),
    );
  }

  Widget _buildContactPhones() {
    return Visibility(
      visible: _service!.phone1 != null || _service!.phone2 != null,
      child: Row(
        crossAxisAlignment:
            (_service!.phone1 != null && _service!.phone2 != null)
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: darkPurple,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_phone_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: defaultPadding),
          Column(
            children: [
              Text(
                _service!.phone1 == null
                    ? _service!.phone2.toString()
                    : _service!.phone1.toString(),
                style: TextStyles.display1().copyWith(height: 1.21),
              ),
              Visibility(
                visible: _service!.phone2 != null,
                child: const SizedBox(height: defaultPadding / 2),
              ),
              Visibility(
                visible: _service!.phone2 != null,
                child: Text(
                  _service!.phone2.toString(),
                  style: TextStyles.display1().copyWith(height: 1.21),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
