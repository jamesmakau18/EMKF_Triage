import 'package:hive_flutter/hive_flutter.dart';
import '../models/triage_record.dart';

class HiveService {
  static const String boxName = 'triage_records';
  
  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TriageRecordAdapter());
    }
    await Hive.openBox<TriageRecord>(boxName);
  }

  Box<TriageRecord> get box => Hive.box<TriageRecord>(boxName);

  Future<void> saveRecord(TriageRecord record) async {
    await box.put(record.id, record);
  }

  Future<void> deleteRecord(String id) async {
    await box.delete(id);
  }

  List<TriageRecord> getAllRecords() {
    return box.values.toList();
  }
}
