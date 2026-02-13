import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/weather_service.dart';
import 'weather_state.dart';

/// 天気UI向けの ViewModel プロバイダーです。
///
/// - [WeatherState]（読み込み状態、天気データ、エラー）を公開します。
/// - 内部は[WeatherViewModel]（[StateNotifier]）が担います。
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
      // ローディング開始時にエラー・パーミッション状態をリセット
      state = state.copyWith(
        isLoading: true,
        error: null,
        isPermissionPermanentlyDenied: false,
      );

      // 天気と位置情報の取得を実行
      await _getLocationAndWeather();
    } on LocationPermissionDeniedException catch (e) {
      // パーミッション拒否：永続か一時かをフラグで保持
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isPermissionPermanentlyDenied: e.isPermanent,
      );
    } catch (e) {
      // その他のエラー：エラーメッセージを状態に設定
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 天気と位置情報の取得を実行
  Future<void> _getLocationAndWeather() async {
    // 現在地の取得
    final position = await _locationService.getCurrentPosition();

    // 天気取得と地名取得を並行実行
    final weatherFuture = _weatherService.getCurrentWeather(
      position.latitude,
      position.longitude,
    );
    final locationFuture = _locationService.getLocationName(
      position.latitude,
      position.longitude,
    );
    final model = await weatherFuture;
    final locationName = await locationFuture;

    // 状態を更新
    state = state.copyWith(
      isLoading: false,
      weather: model,
      locationName: locationName,
    );
  }
}
