class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String photo;
  final double balance;
  final int adsCount;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.photo,
    required this.balance,
    required this.adsCount,
  });

  static UserModel fromJson(data) {
    return UserModel(
      id: data["id"],
      firstName: data["first_name"],
      lastName: data["last_name"],
      phone: data["phone"],
      photo: data["photo"],
      balance: data["balance"],
      adsCount: data["estate_ads_count"],
    );
  }
}
