class TransactionModel {
  final int id;
  final double amount;
  final String date;

  TransactionModel(
      {required this.id, required this.amount, required this.date});

  static TransactionModel fromJson(data) {
    return TransactionModel(
      id: data["id"],
      amount: data["amount"],
      date: data["date"],
    );
  }
}
