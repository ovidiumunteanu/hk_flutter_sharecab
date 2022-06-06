import 'package:flutter/foundation.dart';

class HomeSearchProvider extends ChangeNotifier {
  String search_from = '';
  String search_to = '';

  void setFromSearch(String text) {
    search_from = text;
    notifyListeners();
  }

  void setToSearch(String text) {
    search_to = text;
    notifyListeners();
  }
}
