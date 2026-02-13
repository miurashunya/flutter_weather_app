import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/geocoding_service.dart';
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
  (ref) => LocationSearchViewModel(
    ref.watch(geocodingServiceProvider),
    ref.watch(savedLocationsServiceProvider),
  ),
);

/// 地名検索の状態を管理する ViewModel
class LocationSearchViewModel extends StateNotifier<LocationSearchState> {
  final GeocodingService _geocodingService;
  final SavedLocationsService _service;

  /// [GeocodingService] と [SavedLocationsService] を受け取って ViewModel を生成する
  LocationSearchViewModel(this._geocodingService, this._service)
    : super(const LocationSearchState());

  /// 地名で検索して候補一覧を状態に設定する
  ///
  /// [query] 検索する地名文字列
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null, results: []);
    try {
      // OWM Geocoding API で地名から候補リストを取得
      final geoResults = await _geocodingService.searchLocations(query);
      if (geoResults.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          results: [],
          error: '「$query」に一致する地域が見つかりませんでした',
        );
        return;
      }

      // GeocodingResult を SavedLocation に変換
      final results = geoResults.map((r) => SavedLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: r.name,
        latitude: r.latitude,
        longitude: r.longitude,
      )).toList();

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
