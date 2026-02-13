import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../models/saved_location.dart';
import '../services/saved_locations_service.dart';

/// 地名検索画面の UI 状態を表すデータクラス
class LocationSearchState {
  /// 検索結果の地域リスト
  final List<SavedLocation> results;

  /// 検索中かどうか
  final bool isLoading;

  /// エラーメッセージ（正常時は null）
  final String? error;

  /// 地名検索画面の UI 状態を生成する
  const LocationSearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  /// 指定したフィールドを上書きした新しい [LocationSearchState] を返す
  LocationSearchState copyWith({
    List<SavedLocation>? results,
    bool? isLoading,
    String? error,
  }) {
    return LocationSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// [LocationSearchViewModel] を提供するプロバイダー
final locationSearchViewModelProvider = StateNotifierProvider.autoDispose<
  LocationSearchViewModel,
  LocationSearchState
>(
  (ref) =>
      LocationSearchViewModel(ref.watch(savedLocationsServiceProvider)),
);

/// 地名検索の状態を管理する ViewModel
class LocationSearchViewModel
    extends StateNotifier<LocationSearchState> {
  final SavedLocationsService _service;

  /// [SavedLocationsService] を受け取って ViewModel を生成する
  LocationSearchViewModel(this._service)
    : super(const LocationSearchState());

  /// 地名で検索して候補一覧を状態に設定する
  ///
  /// [query] 検索する地名文字列
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null, results: []);
    try {
      // geocodingで地名から座標を取得
      final locations = await geo.locationFromAddress(query);
      if (locations.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          results: [],
          error: '「$query」に一致する地域が見つかりませんでした',
        );
        return;
      }

      // 各座標から住所情報を取得してSavedLocationリストを構築
      final results = <SavedLocation>[];
      for (final loc in locations.take(5)) {
        final placemarks = await geo.placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        if (placemarks.isEmpty) continue;
        final pm = placemarks.first;

        // 県・市を組み合わせて表示名を生成
        final parts =
            [
              pm.administrativeArea,
              pm.locality,
              pm.subLocality,
            ].where((s) => s != null && s.isNotEmpty).toList();

        final name = parts.isNotEmpty ? parts.join(' ') : query;

        results.add(
          SavedLocation(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            latitude: loc.latitude,
            longitude: loc.longitude,
          ),
        );
      }

      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '検索中にエラーが発生しました: $e',
      );
    }
  }

  /// 地域を保存する
  ///
  /// [location] 保存する地域情報
  Future<void> addLocation(SavedLocation location) async {
    await _service.save(location);
  }
}
