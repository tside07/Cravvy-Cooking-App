import 'package:flutter/foundation.dart';

/// Notifier that holds the current dashboard tab index.
/// Shared between siblings (HomeScreen, etc.) so they can
/// programmatically switch tabs.
class DashboardTabProvider extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void switchTo(int tab) {
    if (_index == tab) return;
    _index = tab;
    notifyListeners();
  }
}
