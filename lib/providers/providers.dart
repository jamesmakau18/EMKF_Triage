import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';
import '../services/api_client.dart';
import '../services/connectivity_service.dart';
import '../repositories/triage_repository.dart';
import '../services/sync_service.dart';
import '../models/triage_record.dart';

final hiveServiceProvider = Provider((ref) => HiveService());
final apiClientProvider = ChangeNotifierProvider((ref) => MockApiClient());
final connectivityServiceProvider = Provider((ref) => ConnectivityService());

final triageRepositoryProvider = Provider((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return TriageRepository(hiveService);
});

final syncServiceProvider = Provider((ref) {
  final repo = ref.watch(triageRepositoryProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final api = ref.watch(apiClientProvider);
  
  final syncService = SyncService(repo, connectivity, api);
  ref.onDispose(() => syncService.dispose());
  return syncService;
});

class RecordsNotifier extends Notifier<List<TriageRecord>> {
  @override
  List<TriageRecord> build() {
    final repo = ref.watch(triageRepositoryProvider);
    
    final listenable = repo.watchChanges();
    void listener() {
      state = repo.getAllRecords();
    }
    
    listenable.addListener(listener);
    ref.onDispose(() {
      listenable.removeListener(listener);
    });

    return repo.getAllRecords();
  }
}

final recordsProvider = NotifierProvider<RecordsNotifier, List<TriageRecord>>(() {
  return RecordsNotifier();
});

final pendingCountProvider = Provider<int>((ref) {
  final records = ref.watch(recordsProvider);
  return records.where((r) => r.status == TriageStatus.pending).length;
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return connectivity.isOnlineStream;
});
