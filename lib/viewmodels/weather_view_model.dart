import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_model.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

/// copyWith でフィールドを「渡さなかった」ことを表すセンチネル値
///
/// `null` を明示的に渡してフィールドをクリアしたい場合と、
/// 単に渡さなかった場合を区別するために使用します。
const _absent = Object();

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

  /// 位置情報パーミッションが永続的に拒否されているかどうか
  ///
  /// `true` の場合、再取得ボタンではなく設定アプリへの誘導を表示します。
  final bool isPermissionPermanentlyDenied;

  /// 天気画面の UI 状態を生成する
  WeatherState({
    this.isLoading = false,
    this.weather,
    this.error,
    this.isPermissionPermanentlyDenied = false,
  });

  /// 指定したフィールドを上書きした新しい [WeatherState] を返す
  ///
  /// [weather] や [error] に `null` を明示的に渡すとそのフィールドがクリアされます。
  /// 引数を省略した場合は既存の値が保持されます。
  WeatherState copyWith({
    bool? isLoading,
    Object? weather = _absent,
    Object? error = _absent,
    bool? isPermissionPermanentlyDenied,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      // _absent のままなら既存値を保持、それ以外は null 含めて上書き
      weather: identical(weather, _absent) ? this.weather : weather as WeatherModel?,
      error: identical(error, _absent) ? this.error : error as String?,
      isPermissionPermanentlyDenied:
          isPermissionPermanentlyDenied ?? this.isPermissionPermanentlyDenied,
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
      // ローディング開始時にエラー・パーミッション状態をリセット
      state = state.copyWith(
        isLoading: true,
        error: null,
        isPermissionPermanentlyDenied: false,
      );
      final position = await _locationService.getCurrentPosition();
      final model = await _weatherService.getCurrentWeather(
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(isLoading: false, weather: model);
    } on LocationPermissionDeniedException catch (e) {
      // パーミッション拒否：永続か一時かをフラグで保持
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isPermissionPermanentlyDenied: e.isPermanent,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
