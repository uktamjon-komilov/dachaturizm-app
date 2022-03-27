import 'package:dachaturizm/helpers/locale_helper.dart';

class Service {
  final int id;
  final String title;
  final String content;
  final String slug;
  final String photo;
  final String? phone1;
  final String? phone2;
  final String? email;

  Service({
    required this.id,
    required this.title,
    required this.content,
    required this.slug,
    required this.photo,
    this.phone1,
    this.phone2,
    this.email,
  });

  static Future<Service> fromJson(data) async {
    String locale = await getCurrentLocale();
    return Service(
      id: data["id"],
      title: data["translations"][locale]["title"],
      content: data["translations"][locale]["content"],
      slug: data["slug"],
      photo: data["image"],
      phone1: data["phone1"],
      phone2: data["phone2"],
      email: data["email"],
    );
  }
}

class ServiceItem {
  final int id;
  final String title;
  final String phone;

  ServiceItem({
    required this.id,
    required this.title,
    required this.phone,
  });

  static Future<ServiceItem> fromJson(data) async {
    String locale = await getCurrentLocale();
    return ServiceItem(
      id: data["id"],
      title: data["translations"][locale]["title"],
      phone: data["phone"],
    );
  }
}
