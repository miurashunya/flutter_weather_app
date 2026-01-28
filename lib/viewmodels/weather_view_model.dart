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

class WeatherState {
  final bool isLoading;
  final WeatherModel? weather;
  final String? error;

  WeatherState({this.isLoading = false, this.weather, this.error});

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

class WeatherViewModel extends StateNotifier<WeatherState> {
  final LocationService _locationService;
  final WeatherService _weatherService;

  WeatherViewModel(this._locationService, this._weatherService)
    : super(WeatherState());

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
