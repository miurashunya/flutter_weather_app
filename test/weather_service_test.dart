import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app/services/weather_service.dart';
import 'package:flutter_weather_app/models/weather_model.dart';

class FakeProvider implements IWeatherProvider {
  final WeatherModel model;
  FakeProvider(this.model);
  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async => model;
}

void main() {
  test('WeatherService returns model from provider', () async {
    final expected = WeatherModel(
      weatherType: WeatherType.clear,
      description: 'clear sky',
      temperature: 21.0,
      feelsLike: 20.0,
      date: DateTime.parse('2020-01-01T00:00:00Z'),
    );

    final service = WeatherService(FakeProvider(expected));
    final res = await service.getCurrentWeather(0.0, 0.0);

    expect(res.weatherType, WeatherType.clear);
    expect(res.description, 'clear sky');
    expect(res.temperature, 21.0);
  });
}
