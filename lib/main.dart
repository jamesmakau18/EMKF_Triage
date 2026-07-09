import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/hive_service.dart';
import 'ui/triage_form_screen.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const TriageApp(),
    ),
  );
}

class TriageApp extends ConsumerStatefulWidget {
  const TriageApp({super.key});

  @override
  ConsumerState<TriageApp> createState() => _TriageAppState();
}

class _TriageAppState extends ConsumerState<TriageApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncServiceProvider).onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start the sync service to listen to connectivity
    ref.watch(syncServiceProvider);
    
    return MaterialApp(
      title: 'Paramedic Triage',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const TriageFormScreen(),
    );
  }
}
