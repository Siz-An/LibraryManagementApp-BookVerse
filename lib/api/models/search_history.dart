import 'package:flutter/foundation.dart';

class SearchHistory with ChangeNotifier {
  List<String> _history = [];

  List<String> get history => _history;

  void addSearchTerm(String term) {
    _history.add(term);
    notifyListeners();
  }
}
