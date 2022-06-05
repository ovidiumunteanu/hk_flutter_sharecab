import 'package:flutter/foundation.dart';

class HomeSearchProvider extends ChangeNotifier {
  String search = '';
 
  void setSearch(String text) {
    search = text;
    notifyListeners();
  }
}