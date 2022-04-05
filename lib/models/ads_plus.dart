import 'package:equatable/equatable.dart';

class AdsPlusModel extends Equatable {
  final int id;
  final String? photo;
  final String? thumnail;
  final int typeId;

  AdsPlusModel({
    required this.id,
    required this.photo,
    required this.thumnail,
    required this.typeId,
  });

  static AdsPlusModel fromJson(Map<String, dynamic> data) {
    return AdsPlusModel(
      id: data["id"],
      photo: data["photo"],
      thumnail: data["thumbnail"],
      typeId: data["type_id"],
    );
  }

  @override
  List<Object?> get props => [this.id];
}
