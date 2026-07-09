import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/triage_record.dart';
import '../providers/providers.dart';

class RecordsListScreen extends ConsumerWidget {
  const RecordsListScreen({super.key});

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red.shade900;
      case 2:
        return Colors.deepOrange.shade700;
      case 3:
        return Colors.amber.shade700;
      case 4:
        return Colors.green.shade700;
      case 5:
        return Colors.blue.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordsProvider);
    final apiClient = ref.watch(apiClientProvider);
    final syncService = ref.read(syncServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triage Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Force Sync',
            onPressed: () {
              syncService.requestFlush();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync requested...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Simulate Random Network Failures'),
            subtitle: const Text('Introduces a 50% chance of API failure.'),
            value: ref.watch(simulateFailuresProvider),
            onChanged: (bool value) {
              ref.read(simulateFailuresProvider.notifier).set(value);
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text('No records found.'))
                : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                // Display newest first
                final record = records[records.length - 1 - index];
                final color = _getPriorityColor(record.priorityLevel);
                final isPending = record.status == TriageStatus.pending;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text(
                        record.priorityLevel.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      record.patientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(record.conditionDescription),
                    trailing: Chip(
                      label: Text(
                        isPending ? 'Pending' : 'Synced',
                        style: TextStyle(
                          color: isPending ? Colors.orange.shade900 : Colors.green.shade900,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
