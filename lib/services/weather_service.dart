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

abstract class IWeatherProvider {
  Future<WeatherModel> getCurrentWeather(double lat, double lon);
}

class OpenWeatherProvider implements IWeatherProvider {
  final WeatherFactory _wf;

  OpenWeatherProvider(String apiKey) : _wf = WeatherFactory(apiKey) {
    if (apiKey.isEmpty) {
      throw Exception('OPENWEATHER_API_KEY is not set');
    }
  }

  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    final w = await _wf.currentWeatherByLocation(lat, lon);
    return WeatherModel.fromWeather(w);
  }
}

class WeatherService {
  final IWeatherProvider _provider;

  WeatherService([IWeatherProvider? provider])
    : _provider =
          provider ??
          OpenWeatherProvider(dotenv.env['OPENWEATHER_API_KEY'] ?? '');

  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    return await _provider.getCurrentWeather(lat, lon);
  }
}
