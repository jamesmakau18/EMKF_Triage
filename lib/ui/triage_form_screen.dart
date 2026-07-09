import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/triage_record.dart';
import '../providers/providers.dart';
import 'records_list_screen.dart';

class TriageFormScreen extends ConsumerStatefulWidget {
  const TriageFormScreen({super.key});

  @override
  ConsumerState<TriageFormScreen> createState() => _TriageFormScreenState();
}

class _TriageFormScreenState extends ConsumerState<TriageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _conditionController = TextEditingController();
  int? _priorityLevel;

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

  void _submit() async {
    if (_formKey.currentState!.validate() && _priorityLevel != null) {
      final record = TriageRecord(
        id: const Uuid().v4(),
        patientName: _nameController.text.trim(),
        conditionDescription: _conditionController.text.trim(),
        priorityLevel: _priorityLevel!,
        status: TriageStatus.pending,
      );

      final repo = ref.read(triageRepositoryProvider);
      await repo.createRecord(record);

      // Trigger sync manually just in case
      ref.read(syncServiceProvider).requestFlush();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Triage record saved.')),
        );
      }

      // Reset form
      _nameController.clear();
      _conditionController.clear();
      setState(() {
        _priorityLevel = null;
      });
    } else if (_priorityLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a priority level.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref.watch(pendingCountProvider);
    final isOnlineAsync = ref.watch(isOnlineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intake Form'),
        actions: [
          Center(
            child: isOnlineAsync.when(
              data: (online) => Icon(
                online ? Icons.wifi : Icons.wifi_off,
                color: online ? Colors.green : Colors.red,
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text(pendingCount.toString()),
              child: const Icon(Icons.list_alt),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecordsListScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conditionController,
                  decoration: const InputDecoration(
                    labelText: 'Condition Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Priority Level',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(5, (index) {
                    final priority = index + 1;
                    final isSelected = _priorityLevel == priority;
                    final color = _getPriorityColor(priority);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _priorityLevel = priority;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          priority.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : color,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _priorityLevel != null
                          ? _getPriorityColor(_priorityLevel!)
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SUBMIT TRIAGE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
