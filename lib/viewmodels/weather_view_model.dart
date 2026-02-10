import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

/// 天気UI向けの ViewModel プロバイダーです。
///
/// - [WeatherState]（読み込み状態、天気データ、エラー）を公開します。内部は
///   [WeatherViewModel]（[StateNotifier]）が担います。
/// - `autoDispose` を使用しており、不要になったら状態がクリアされます。
/// - テストでは依存プロバイダー（例: [weatherServiceProvider]）をオーバーライドして
///   フェイクを注入し、振る舞いをコントロールできます。
final weatherViewModelProvider =
    StateNotifierProvider.autoDispose<WeatherViewModel, WeatherState>(
      (ref) => WeatherViewModel(
        ref.watch(locationServiceProvider),
        ref.watch(weatherServiceProvider),
      ),
    );

/// 天気画面の UI 状態を表すデータクラス
class WeatherState {
  /// データ取得中かどうか
  final bool isLoading;

  /// 取得済みの天気データ（未取得時は null）
  final WeatherModel? weather;

  /// エラーメッセージ（正常時は null）
  final String? error;

  /// 天気画面の UI 状態を生成する
  WeatherState({this.isLoading = false, this.weather, this.error});

  /// 指定したフィールドを上書きした新しい [WeatherState] を返す
  WeatherState copyWith({
    bool? isLoading,
    WeatherModel? weather,
    String? error,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      weather: weather ?? this.weather,
      error: error ?? this.error,
    );
  }
}

/// 天気画面の状態を管理する ViewModel
class WeatherViewModel extends StateNotifier<WeatherState> {
  final LocationService _locationService;
  final WeatherService _weatherService;

  /// [LocationService] と [WeatherService] を受け取って ViewModel を生成する
  WeatherViewModel(this._locationService, this._weatherService)
    : super(WeatherState());

  /// 現在位置の天気情報を取得して状態を更新する
  ///
  /// 取得中は [WeatherState.isLoading] が `true` になります。
  /// エラー時は [WeatherState.error] にメッセージが設定されます。
  Future<void> fetchWeather() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final position = await _locationService.getCurrentPosition();
      final model = await _weatherService.getCurrentWeather(
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(isLoading: false, weather: model);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
