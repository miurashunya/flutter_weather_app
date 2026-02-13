import '../../../core/models/weather_model.dart';

/// copyWith でフィールドを「渡さなかった」ことを表すセンチネル値
///
/// `null` を明示的に渡してフィールドをクリアしたい場合と、
/// 単に渡さなかった場合を区別するために使用します。
const _absent = Object();

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

  /// 取得した地名（県・市）の文字列（未取得時は null）
  final String? locationName;

  /// 天気画面の UI 状態を生成する
  WeatherState({
    this.isLoading = false,
    this.weather,
    this.error,
    this.isPermissionPermanentlyDenied = false,
    this.locationName,
  });

  /// 指定したフィールドを上書きした新しい [WeatherState] を返す
  ///
  /// [weather]、[error]、[locationName] に `null` を明示的に渡すとそのフィールドがクリアされます。
  /// 引数を省略した場合は既存の値が保持されます。
  WeatherState copyWith({
    bool? isLoading,
    Object? weather = _absent,
    Object? error = _absent,
    bool? isPermissionPermanentlyDenied,
    Object? locationName = _absent,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      // _absent のままなら既存値を保持、それ以外は null 含めて上書き
      weather:
          identical(weather, _absent) ? this.weather : weather as WeatherModel?,
      error: identical(error, _absent) ? this.error : error as String?,
      isPermissionPermanentlyDenied:
          isPermissionPermanentlyDenied ?? this.isPermissionPermanentlyDenied,
      locationName:
          identical(locationName, _absent)
              ? this.locationName
              : locationName as String?,
    );
  }
}
