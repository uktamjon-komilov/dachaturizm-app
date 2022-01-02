class EstateRatingModel {
  final int total;
  final double averageRating;
  final Map<String, RatingModel> ratings;

  EstateRatingModel({
    required this.total,
    required this.averageRating,
    required this.ratings,
  });

  static EstateRatingModel fromJson(data) {
    return EstateRatingModel(
      total: data["total"],
      averageRating: double.parse(
        data["average_rating"].toStringAsFixed(1),
      ),
      ratings: {
        "5": RatingModel.fromJson(data["5"]),
        "4": RatingModel.fromJson(data["4"]),
        "3": RatingModel.fromJson(data["3"]),
        "2": RatingModel.fromJson(data["2"]),
        "1": RatingModel.fromJson(data["1"]),
      },
    );
  }
}

class RatingModel {
  final double percent;
  final int count;

  RatingModel({required this.percent, required this.count});

  static RatingModel fromJson(data) {
    return RatingModel(
      percent: double.parse(
        data["percent"].toStringAsFixed(1),
      ),
      count: data["count"],
    );
  }
}
