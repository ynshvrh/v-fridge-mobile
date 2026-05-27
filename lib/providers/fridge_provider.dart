import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/services.dart';
import '../models/api_models.dart';
import 'providers.dart';

@immutable
class FridgeState {
  final List<Fridge> all;

  /// Persisted "active" fridge id (the X-Fridge-Id the client sends). `null` means
  /// the server picks the caller's first owned fridge as fallback.
  final int? activeId;

  const FridgeState({required this.all, required this.activeId});

  /// Effective active fridge — the persisted choice if it still exists, otherwise
  /// the first fridge in the list, otherwise null.
  Fridge? get active {
    if (all.isEmpty) return null;
    if (activeId != null) {
      for (final f in all) {
        if (f.id == activeId) return f;
      }
    }
    return all.first;
  }

  FridgeState copyWith({List<Fridge>? all, int? activeId, bool clearActive = false}) =>
      FridgeState(
        all: all ?? this.all,
        activeId: clearActive ? null : (activeId ?? this.activeId),
      );
}

/// Owns the fridge list + active selection. Loaded once on first access; refreshed
/// after any mutation (create / delete / leave / accept invite) by callers that
/// hold a reference to the notifier.
class FridgeController extends StateNotifier<AsyncValue<FridgeState>> {
  FridgeController(this._api, this._fridges) : super(const AsyncValue.loading()) {
    refresh();
  }

  final ApiClient _api;
  final FridgesService _fridges;

  Future<void> refresh() async {
    try {
      final list = await _fridges.list();
      final activeId = await _api.getActiveFridgeId();
      state = AsyncValue.data(FridgeState(all: list, activeId: activeId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setActive(int? id) async {
    await _api.setActiveFridgeId(id);
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(
        activeId: id,
        clearActive: id == null,
      ));
    }
  }
}

final fridgeControllerProvider =
    StateNotifierProvider<FridgeController, AsyncValue<FridgeState>>((ref) {
  return FridgeController(
    ref.watch(apiClientProvider),
    ref.watch(fridgesServiceProvider),
  );
});

/// Convenience selector — true active fridge id (resolved through the fallback
/// logic). Returns null only while the list is loading or the user has no fridge.
final activeFridgeIdProvider = Provider<int?>((ref) {
  final state = ref.watch(fridgeControllerProvider);
  return state.value?.active?.id;
});
