class PopularPlaceModel {
  final int id;
  final String title;

  PopularPlaceModel({
    required this.id,
    required this.title,
  });

  static PopularPlaceModel fromJson(data) {
    return PopularPlaceModel(
      id: data["id"],
      title: data["title"],
    );
  }
}
