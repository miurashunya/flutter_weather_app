import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/weather.dart';
import '../models/weather_model.dart';

/// [WeatherService] を提供するプロバイダーです。
///
/// - `autoDispose` を使用しており、利用されなくなったら自動的に解放されます。
/// - [WeatherService] はテスト用に [IWeatherProvider] を受け取れるため、テストでは
///   このプロバイダーをオーバーライドして偽のプロバイダーを注入してください。
///   例: `ProviderScope(overrides: [weatherServiceProvider.overrideWithValue(fakeService)])`.
final weatherServiceProvider = Provider.autoDispose((ref) => WeatherService());

/// 天気情報プロバイダーのインターフェース
abstract class IWeatherProvider {
  /// 指定した緯度・経度の現在の天気情報を取得する
  ///
  /// [lat] 緯度, [lon] 経度
  Future<WeatherModel> getCurrentWeather(double lat, double lon);
}

/// OpenWeatherMap API を使用した天気情報プロバイダー実装
class OpenWeatherProvider implements IWeatherProvider {
  final WeatherFactory _wf;

  /// OpenWeatherMap API キーを使用して天気情報プロバイダーを生成する
  ///
  /// [apiKey] OpenWeatherMap API キー。空文字の場合は [ArgumentError] をスローします。
  OpenWeatherProvider(String apiKey) : _wf = WeatherFactory(apiKey) {
    if (apiKey.isEmpty) {
      throw ArgumentError.value(
        apiKey,
        'apiKey',
        'OPENWEATHER_API_KEY が設定されていません',
      );
    }
  }

  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    final w = await _wf.currentWeatherByLocation(lat, lon);
    return WeatherModel.fromWeather(w);
  }
}

/// 天気情報を取得するサービスクラス
class WeatherService {
  final IWeatherProvider _provider;

  /// 天気情報サービスを生成する
  ///
  /// [provider] を省略した場合は [OpenWeatherProvider] を使用します。
  /// テスト時はフェイク実装を渡してください。
  WeatherService([IWeatherProvider? provider])
    : _provider =
          provider ??
          OpenWeatherProvider(dotenv.env['OPENWEATHER_API_KEY'] ?? '');

  /// 指定した緯度・経度の現在の天気情報を取得する
  ///
  /// [lat] 緯度, [lon] 経度
  Future<WeatherModel> getCurrentWeather(double lat, double lon) {
    return _provider.getCurrentWeather(lat, lon);
  }
}
