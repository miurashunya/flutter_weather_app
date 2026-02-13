import 'package:weather_animation/weather_animation.dart';
import '../models/weather_model.dart';

/// [WeatherType] に天気アニメーションシーンへの変換機能を追加する拡張
extension WeatherTypeSceneX on WeatherType {
  /// [WeatherType] を対応する [WeatherScene] に変換する
  ///
  /// `clouds` は専用の [CloudyWidget] で表示するため、
  /// このメソッドの戻り値は使用しないが、一貫性のために定義しています。
  WeatherScene toScene() {
    switch (this) {
      case WeatherType.clear:
        return WeatherScene.scorchingSun;
      case WeatherType.clouds:
        return WeatherScene.sunset;
      case WeatherType.rain:
      case WeatherType.drizzle:
        return WeatherScene.rainyOvercast;
      case WeatherType.thunderstorm:
        return WeatherScene.stormy;
      case WeatherType.snow:
        return WeatherScene.snowfall;
      case WeatherType.mist:
      case WeatherType.fog:
      default:
        return WeatherScene.weatherEvery;
    }
  }
}
