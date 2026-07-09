import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/triage_record.dart';
import '../services/hive_service.dart';

class TriageRepository {
  final HiveService _hiveService;

  TriageRepository(this._hiveService);

  Future<void> createRecord(TriageRecord record) async {
    await _hiveService.saveRecord(record);
  }

  List<TriageRecord> getAllRecords() {
    return _hiveService.getAllRecords();
  }

  List<TriageRecord> getUnsyncedRecords() {
    return _hiveService.getAllRecords().where((r) => r.status == TriageStatus.pending).toList();
  }

  Future<void> markSynced(String id) async {
    final box = _hiveService.box;
    final record = box.get(id);
    if (record != null) {
      record.status = TriageStatus.inTransit;
      await _hiveService.saveRecord(record);
    }
  }

  ValueListenable<Box<TriageRecord>> watchChanges() {
    return _hiveService.box.listenable();
  }
}
