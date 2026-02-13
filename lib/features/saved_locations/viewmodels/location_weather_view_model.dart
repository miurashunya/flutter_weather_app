import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/saved_location.dart';
import '../../../core/services/weather_service.dart';
import '../../home/viewmodels/weather_state.dart';

/// 特定地域の天気を取得する ViewModel を提供するプロバイダーファミリー
///
/// [SavedLocation] をパラメータとして受け取り、その地域の天気状態を管理します。
final locationWeatherViewModelProvider = StateNotifierProvider.autoDispose
    .family<LocationWeatherViewModel, WeatherState, SavedLocation>(
      (ref, location) => LocationWeatherViewModel(
        ref.watch(weatherServiceProvider),
        location,
      ),
    );

/// 特定地域の天気画面の状態を管理する ViewModel
class LocationWeatherViewModel extends StateNotifier<WeatherState> {
  final WeatherService _weatherService;
  final SavedLocation _location;

  /// [WeatherService] と [SavedLocation] を受け取って ViewModel を生成する
  LocationWeatherViewModel(this._weatherService, this._location)
    : super(WeatherState());

  /// 保存済み地域の座標を使って天気情報を取得して状態を更新する
  Future<void> fetchWeather() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      isPermissionPermanentlyDenied: false,
    );
    try {
      // 保存済み緯度経度でAPIを呼び出し
      final model = await _weatherService.getCurrentWeather(
        _location.latitude,
        _location.longitude,
      );
      state = state.copyWith(
        isLoading: false,
        weather: model,
        locationName: _location.name,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
