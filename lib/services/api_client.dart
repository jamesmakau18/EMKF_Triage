import 'dart:math';
import '../models/triage_record.dart';

class MockApiClient {
  final Random _random = Random();
  bool allowFailures = true;

  Future<bool> submitTriage(TriageRecord record) async {
    // Artificial 2-second delay
    await Future.delayed(const Duration(seconds: 2));

    // Random failure simulation (e.g., 30% chance to fail)
    if (allowFailures && _random.nextDouble() < 0.3) {
      throw Exception('Simulated network failure on POST /api/v1/triage');
    }

    // Success
    return true;
  }
}
