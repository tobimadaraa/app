import 'package:flutter/material.dart';

class DodgeListEventNotifier extends ChangeNotifier {
  void triggerUpdate() {
    notifyListeners(); // 🔔 Notify all listeners (DodgeListScreen) that an update happened
  }
}

final dodgeListEventNotifier = DodgeListEventNotifier();
