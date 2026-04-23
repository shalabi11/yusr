import 'dart:async';
import 'package:flutter/foundation.dart';

/// Interface for features that can be synchronized with a remote backend.
abstract class ISyncable {
  /// Unique identifier for the syncable feature (e.g., 'settings', 'quran_bookmarks').
  String get syncId;

  /// Performs the synchronization. 
  /// Usually involves loading local data, fetching remote data, merging, and updating both.
  Future<void> sync();
}

/// Orchestrates synchronization across all registered syncable features.
class SyncOrchestrator {
  final List<ISyncable> _syncables = [];
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  void register(ISyncable syncable) {
    if (!_syncables.any((s) => s.syncId == syncable.syncId)) {
      _syncables.add(syncable);
    }
  }

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    debugPrint('[SyncOrchestrator] Starting global sync...');

    try {
      final futures = _syncables.map((s) async {
        try {
          await s.sync();
          debugPrint('[SyncOrchestrator] Sync completed for: ${s.syncId}');
        } catch (e) {
          debugPrint('[SyncOrchestrator] Sync failed for ${s.syncId}: $e');
        }
      });
      await Future.wait(futures);
    } finally {
      _isSyncing = false;
      debugPrint('[SyncOrchestrator] Global sync finished.');
    }
  }
}
