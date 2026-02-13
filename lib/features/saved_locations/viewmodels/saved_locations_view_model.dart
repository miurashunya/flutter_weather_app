import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/saved_location.dart';
import '../services/saved_locations_service.dart';

/// 保存地域一覧画面の UI 状態を表すデータクラス
class SavedLocationsState {
  /// 保存済み地域のリスト
  final List<SavedLocation> locations;

  /// データ読み込み中かどうか
  final bool isLoading;

  /// エラーメッセージ（正常時は null）
  final String? error;

  /// 保存地域一覧の UI 状態を生成する
  const SavedLocationsState({
    this.locations = const [],
    this.isLoading = false,
    this.error,
  });

  /// 指定したフィールドを上書きした新しい [SavedLocationsState] を返す
  SavedLocationsState copyWith({
    List<SavedLocation>? locations,
    bool? isLoading,
    String? error,
  }) {
    return SavedLocationsState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// [SavedLocationsViewModel] を提供するプロバイダー
final savedLocationsViewModelProvider = StateNotifierProvider.autoDispose<
  SavedLocationsViewModel,
  SavedLocationsState
>((ref) => SavedLocationsViewModel(ref.watch(savedLocationsServiceProvider)));

/// 保存地域一覧の状態を管理する ViewModel
class SavedLocationsViewModel
    extends StateNotifier<SavedLocationsState> {
  final SavedLocationsService _service;

  /// [SavedLocationsService] を受け取って ViewModel を生成する
  SavedLocationsViewModel(this._service) : super(const SavedLocationsState());

  /// SharedPreferencesから保存地域を読み込んで状態を更新する
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final locations = await _service.loadAll();
      state = state.copyWith(locations: locations, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '地域の読み込みに失敗しました: $e',
      );
    }
  }

  /// 指定したIDの地域を削除して状態を更新する
  ///
  /// [id] 削除対象の地域ID
  Future<void> delete(String id) async {
    try {
      await _service.delete(id);
      // 状態から該当地域を除外
      state = state.copyWith(
        locations: state.locations.where((loc) => loc.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: '地域の削除に失敗しました: $e');
    }
  }
}
