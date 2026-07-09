import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/triage_record.dart';

class MockApiClient extends ChangeNotifier {
  final Random _random = Random();
  bool _simulateFailures = false;

  bool get simulateFailures => _simulateFailures;

  void toggleFailures(bool value) {
    _simulateFailures = value;
    notifyListeners();
  }

  Future<bool> submitTriage(TriageRecord record) async {
    // Artificial 2-second delay
    await Future.delayed(const Duration(seconds: 2));

    // Random failure simulation (50% chance to fail)
    if (_simulateFailures && _random.nextDouble() < 0.5) {
      throw Exception('Simulated network failure on POST /api/v1/triage');
    }

    // Success
    return true;
  }
}
