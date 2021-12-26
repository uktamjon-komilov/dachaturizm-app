import 'package:dachaturizm/helpers/locale_helper.dart';
import 'package:dachaturizm/models/estate_model.dart';
import 'package:dachaturizm/models/user_model.dart';

class MessageModel {
  final int id;
  final UserModel sender;
  final UserModel receiver;
  final String text;
  final int estateId;
  final EstateModel estateDetail;

  MessageModel({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.text,
    required this.estateId,
    required this.estateDetail,
  });

  static Future<MessageModel> fromJson(data) async {
    EstateModel estate = await EstateModel.fromJson(data["estate_detail"]);

    return MessageModel(
        id: data["id"],
        sender: UserModel.fromJson(data["sender"]),
        receiver: UserModel.fromJson(data["receiver"]),
        text: data["text"],
        estateId: data["estate"],
        estateDetail: estate);
  }
}
