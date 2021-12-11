import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:equatable/equatable.dart';

class CurrencyModel extends Equatable {
  final int id;
  final String title;

  CurrencyModel({required this.id, required this.title});

  static Future<CurrencyModel> fromJson(data) async {
    String locale = await getCurrentLocale();
    return CurrencyModel(
        id: data["id"], title: data["translations"][locale]["title"]);
  }

  @override
  List<Object?> get props => [title];
}
