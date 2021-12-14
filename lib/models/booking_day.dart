import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class BookingDay extends Equatable {
  final int id;
  final String date;
  late DateTime datetime;

  BookingDay({required this.id, required this.date}) {
    datetime = DateFormat("yyyy-MM-dd").parse(date);
  }

  static BookingDay fromJson(data) {
    return BookingDay(id: data["id"], date: data["date"]);
  }

  static BookingDay toObj(DateTime date) {
    return BookingDay(id: 0, date: "${date.year}-${date.month}-${date.day}");
  }

  @override
  List<Object?> get props => [date];
}
