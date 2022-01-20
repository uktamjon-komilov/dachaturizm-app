import 'package:dachaturizm/components/app_bar.dart';
import 'package:dachaturizm/components/bottom_navbar.dart';
import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/helpers/url_helper.dart';
import 'package:dachaturizm/models/service_model.dart';
import 'package:dachaturizm/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:sizer/sizer.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      Service data = ModalRoute.of(context)?.settings.arguments as Service;
      setState(() {
        _service = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildNavigationalAppBar(context, _service!.title),
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
                      SizedBox(height: 24),
                      Text(
                        _service!.content +
                            _service!.content +
                            _service!.content +
                            _service!.content,
                        style: TextStyle(
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
                            SizedBox(height: defaultPadding),
                            Text(
                              Locales.string(context, "for_contact"),
                              style: TextStyles.display1(),
                            ),
                            SizedBox(height: defaultPadding),
                            _buildContactPhones(),
                            SizedBox(height: defaultPadding),
                            _buildContactEmail(),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
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
            child: Icon(
              Icons.email_rounded,
              color: Colors.white,
            ),
          ),
          SizedBox(width: defaultPadding),
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
            child: Icon(
              Icons.local_phone_rounded,
              color: Colors.white,
            ),
          ),
          SizedBox(width: defaultPadding),
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
                  child: SizedBox(height: defaultPadding / 2)),
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
