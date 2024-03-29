import 'package:dachaturizm/constants.dart';
import 'package:dachaturizm/models/service_model.dart';
import 'package:dachaturizm/repository/base_repository.dart';
import 'package:dio/dio.dart';

class ServicesRepository extends BaseRepository {
  final Dio dio;

  ServicesRepository({required this.dio});

  Future<List<Service>> getServices() async {
    List<Service> services = [];
    final url = "${baseUrl}api/services/";
    try {
      final respose = await dio.get(url);
      if (isSuccessStatus(respose)) {
        await respose.data.forEach((item) async {
          Service service = await Service.fromJson(item);
          services.add(service);
        });
      }
    } catch (e) {}

    return services;
  }

  Future<List<ServiceItem>> getServiceItems(int id) async {
    List<ServiceItem> items = [];
    final url = "${baseUrl}api/services/${id}/items/";
    try {
      final respose = await dio.get(url);
      if (isSuccessStatus(respose)) {
        await respose.data.forEach((elem) async {
          ServiceItem item = await ServiceItem.fromJson(elem);
          items.add(item);
        });
      }
    } catch (e) {}

    return items;
  }
}
