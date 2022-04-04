import 'package:cached_network_image/cached_network_image.dart';
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
          ? const Center(
              child: const CircularProgressIndicator(),
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
                    _buildMainImage(),
                    const SizedBox(height: 24),
                    _buildServiceContent(),
                    _buildContactDetails(context),
                    const SizedBox(height: 24),
                    ..._items
                        .map(
                          (item) => _buildServiceItem(item, context),
                        )
                        .toList()
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildServiceItem(ServiceItem item, BuildContext context) {
    return IntrinsicHeight(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 100.w,
          maxHeight: 100.h,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceItemImage(item),
              _buildServiceItemContent(item),
              _buildServiceItemContact(context, item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItemContact(BuildContext context, ServiceItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Locales.string(context, "phone") + ": " + item.phone,
          style: TextStyles.display2().copyWith(
            overflow: TextOverflow.ellipsis,
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
      ],
    );
  }

  Widget _buildServiceItemContent(ServiceItem item) {
    return Flexible(
      child: Text(
        item.title,
        style: const TextStyle(
          fontSize: 13,
          height: 1.92,
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
        ),
        maxLines: 10,
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildServiceItemImage(ServiceItem item) {
    return Visibility(
      visible: item.photo != null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: fixMediaUrl(item.photo.toString()),
        ),
      ),
    );
  }

  Widget _buildContactDetails(BuildContext context) {
    return Visibility(
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
    );
  }

  Widget _buildServiceContent() {
    return Text(
      _service!.content,
      style: const TextStyle(
        fontSize: 13,
        height: 1.92,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildMainImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        width: 100.w,
        child: Image.network(
          fixMediaUrl(_service!.photo),
          fit: BoxFit.cover,
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
