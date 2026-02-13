import 'package:weather/weather.dart' as w;

/// 天気の種類を表す列挙型
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

  /// 日本語ラベル
  final String label;

  /// 日本語ラベルを持つ天気種別を生成する
  const WeatherType(this.label);
}

/// 天気情報を保持するデータクラス
class WeatherModel {
  /// 天気の種類
  final WeatherType weatherType;

  /// 天気の説明（英語）
  final String? description;

  /// 気温（摂氏）
  final double? temperature;

  /// 体感温度（摂氏）
  final double? feelsLike;

  /// 取得日時
  final DateTime? date;

  /// 天気情報を保持するデータクラスを生成する
  WeatherModel({
    this.weatherType = WeatherType.unknown,
    this.description,
    this.temperature,
    this.feelsLike,
    this.date,
  });

  /// [w.Weather] オブジェクトから [WeatherModel] を生成するファクトリーコンストラクタ
  ///
  /// [src] OpenWeatherMap APIから取得した天気データ
  factory WeatherModel.fromWeather(w.Weather src) {
    return WeatherModel(
      weatherType: _parseWeatherType(src.weatherMain),
      description: src.weatherDescription,
      temperature: src.temperature?.celsius,
      feelsLike: src.tempFeelsLike?.celsius,
      date: src.date,
    );
  }

  /// API レスポンスの天気文字列を [WeatherType] に変換する
  ///
  /// [s] OpenWeatherMap API の `weather.main` フィールド値
  static WeatherType _parseWeatherType(String? s) {
    switch ((s ?? '').toLowerCase()) {
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
}
