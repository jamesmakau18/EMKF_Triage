import 'package:hive/hive.dart';

enum TriageStatus { pending, inTransit }

class TriageRecord {
  final String id;
  final String patientName;
  final String conditionDescription;
  final int priorityLevel; // 1 to 5
  TriageStatus status;

  TriageRecord({
    required this.id,
    required this.patientName,
    required this.conditionDescription,
    required this.priorityLevel,
    required this.status,
  });

  // Helper for JSON/API simulation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'conditionDescription': conditionDescription,
      'priorityLevel': priorityLevel,
      'status': status.name,
    };
  }
}

class TriageRecordAdapter extends TypeAdapter<TriageRecord> {
  @override
  final int typeId = 0;

  @override
  TriageRecord read(BinaryReader reader) {
    return TriageRecord(
      id: reader.readString(),
      patientName: reader.readString(),
      conditionDescription: reader.readString(),
      priorityLevel: reader.readInt(),
      status: TriageStatus.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, TriageRecord obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.patientName);
    writer.writeString(obj.conditionDescription);
    writer.writeInt(obj.priorityLevel);
    writer.writeInt(obj.status.index);
  }
}
