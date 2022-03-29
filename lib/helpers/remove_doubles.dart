import 'package:dachaturizm/models/estate_model.dart';

List<EstateModel> removeDoubleEstates(List<EstateModel> estates) {
  List<EstateModel> _estates = [];
  List<int> _estateIds = [];

  for (int i = 0; i < estates.length; i++) {
    if (!_estateIds.contains(estates[i].id)) {
      _estates.add(estates[i]);
    }
    _estateIds.add(estates[i].id);
  }

  return _estates;
}
