import 'dart:math';
import '../models/triage_record.dart';

class MockApiClient {
  final Random _random = Random();
  final bool simulateFailures;

  MockApiClient({this.simulateFailures = false});

  Future<bool> submitTriage(TriageRecord record) async {
    // Artificial 2-second delay
    await Future.delayed(const Duration(seconds: 2));

    // Random failure simulation (50% chance to fail)
    if (simulateFailures && _random.nextDouble() < 0.5) {
      throw Exception('Simulated network failure on POST /api/v1/triage');
    }

    // Success
    return true;
  }
}
