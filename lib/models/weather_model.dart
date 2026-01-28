import 'package:weather/weather.dart' as w;

enum WeatherType {
  clear('晴れ'),
  clouds('曇り'),
  rain('雨'),
  drizzle('小雨'),
  thunderstorm('雷雨'),
  snow('雪'),
  mist('霧'),
  smoke('煙霧'),
  haze('靄'),
  dust('砂塵'),
  fog('霧'),
  sand('砂'),
  ash('灰'),
  squall('スコール'),
  tornado('竜巻'),
  unknown('不明');

  final String label;
  const WeatherType(this.label);
}

class WeatherModel {
  final WeatherType weatherType;
  final String? description;
  final double? temperature;
  final double? feelsLike;
  final DateTime? date;

  WeatherModel({
    this.weatherType = WeatherType.unknown,
    this.description,
    this.temperature,
    this.feelsLike,
    this.date,
  });

  factory WeatherModel.fromWeather(w.Weather src) {
    WeatherType parse(String? s) {
      final v = (s ?? '').toLowerCase();
      switch (v) {
        case 'clear':
          return WeatherType.clear;
        case 'clouds':
          return WeatherType.clouds;
        case 'rain':
          return WeatherType.rain;
        case 'drizzle':
          return WeatherType.drizzle;
        case 'thunderstorm':
          return WeatherType.thunderstorm;
        case 'snow':
          return WeatherType.snow;
        case 'mist':
          return WeatherType.mist;
        case 'smoke':
          return WeatherType.smoke;
        case 'haze':
          return WeatherType.haze;
        case 'dust':
          return WeatherType.dust;
        case 'fog':
          return WeatherType.fog;
        case 'sand':
          return WeatherType.sand;
        case 'ash':
          return WeatherType.ash;
        case 'squall':
          return WeatherType.squall;
        case 'tornado':
          return WeatherType.tornado;
        default:
          return WeatherType.unknown;
      }
    }

    return WeatherModel(
      weatherType: parse(src.weatherMain),
      description: src.weatherDescription,
      temperature: src.temperature?.celsius,
      feelsLike: src.tempFeelsLike?.celsius,
      date: src.date,
    );
  }
}
