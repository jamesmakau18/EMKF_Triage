import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:triage_app/models/triage_record.dart';
import 'package:triage_app/repositories/triage_repository.dart';
import 'package:triage_app/services/api_client.dart';
import 'package:triage_app/services/connectivity_service.dart';
import 'package:triage_app/services/sync_service.dart';

class MockTriageRepository extends Mock implements TriageRepository {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockMockApiClient extends Mock implements MockApiClient {}

void main() {
  late MockTriageRepository mockRepo;
  late MockConnectivityService mockConnectivity;
  late MockMockApiClient mockApi;
  late SyncService syncService;
  late StreamController<bool> connectivityStreamController;

  setUp(() {
    mockRepo = MockTriageRepository();
    mockConnectivity = MockConnectivityService();
    mockApi = MockMockApiClient();
    connectivityStreamController = StreamController<bool>.broadcast();

    when(() => mockConnectivity.isOnlineStream).thenAnswer((_) => connectivityStreamController.stream);
    when(() => mockConnectivity.checkIsOnline()).thenAnswer((_) async => true);

    syncService = SyncService(mockRepo, mockConnectivity, mockApi);
  });

  tearDown(() {
    syncService.dispose();
    connectivityStreamController.close();
  });

  test('SyncService flushes queue when online connectivity is detected', () async {
    final record = TriageRecord(
      id: '1',
      patientName: 'John',
      conditionDescription: 'Pain',
      priorityLevel: 3,
      status: TriageStatus.pending,
    );

    when(() => mockRepo.getUnsyncedRecords()).thenReturn([record]);
    when(() => mockApi.submitTriage(record)).thenAnswer((_) async => true);
    when(() => mockRepo.markSynced(record.id)).thenAnswer((_) async {});

    // Trigger online
    connectivityStreamController.add(true);
    
    // Let async operations flush
    await Future.delayed(const Duration(milliseconds: 50));

    verify(() => mockRepo.getUnsyncedRecords()).called(1);
    verify(() => mockApi.submitTriage(record)).called(1);
    verify(() => mockRepo.markSynced(record.id)).called(1);
  });

  test('SyncService handles API failure gracefully without crashing', () async {
    final record = TriageRecord(
      id: '1',
      patientName: 'John',
      conditionDescription: 'Pain',
      priorityLevel: 3,
      status: TriageStatus.pending,
    );

    when(() => mockRepo.getUnsyncedRecords()).thenReturn([record]);
    when(() => mockApi.submitTriage(record)).thenThrow(Exception('Network Error'));

    // Trigger online
    connectivityStreamController.add(true);
    
    await Future.delayed(const Duration(milliseconds: 50));

    verify(() => mockRepo.getUnsyncedRecords()).called(1);
    verify(() => mockApi.submitTriage(record)).called(1);
    verifyNever(() => mockRepo.markSynced(record.id));
  });
}
