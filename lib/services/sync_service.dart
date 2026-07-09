import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/triage_record.dart';
import '../repositories/triage_repository.dart';
import 'api_client.dart';
import 'connectivity_service.dart';

class SyncService {
  final TriageRepository _repository;
  final ConnectivityService _connectivityService;
  final MockApiClient _apiClient;
  
  bool _isFlushing = false;
  bool _flushRequested = false;
  StreamSubscription? _connectivitySub;

  SyncService(this._repository, this._connectivityService, this._apiClient) {
    _init();
  }

  void _init() async {
    // Check initial connectivity and flush if online
    if (await _connectivityService.checkIsOnline()) {
      requestFlush();
    }

    _connectivitySub = _connectivityService.isOnlineStream.listen((isOnline) {
      if (isOnline) {
        requestFlush();
      }
    });
  }

  void dispose() {
    _connectivitySub?.cancel();
  }

  Future<void> requestFlush() async {
    if (_isFlushing) {
      _flushRequested = true;
      return;
    }
    
    _isFlushing = true;
    _flushRequested = false;

    try {
      await _flushQueue();
    } finally {
      _isFlushing = false;
      if (_flushRequested) {
        // Run again if another request came in while flushing
        requestFlush();
      }
    }
  }

  Future<void> _flushQueue() async {
    // Check if online before starting
    if (!await _connectivityService.checkIsOnline()) return;

    final pendingRecords = _repository.getUnsyncedRecords();
    if (pendingRecords.isEmpty) return;

    for (final record in pendingRecords) {
      try {
        final success = await _apiClient.submitTriage(record);
        if (success) {
          await _repository.markSynced(record.id);
        }
      } catch (e) {
        debugPrint('Failed to sync record ${record.id}: $e');
        // Prompt rule: "per-record try/catch so one failure doesn't block the rest of the batch"
      }
    }
  }

  // Hook for AppLifecycleState.resumed
  void onAppResumed() async {
    if (await _connectivityService.checkIsOnline()) {
      requestFlush();
    }
  }
}
