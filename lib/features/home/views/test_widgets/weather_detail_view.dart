import 'package:flutter/material.dart';
import 'package:flutter_weather_app/core/utils/time_of_day_utils.dart';
import 'package:flutter_weather_app/features/home/views/weather_widgets/night_widget.dart';
import 'package:flutter_weather_app/features/home/views/weather_widgets/sunny_widget.dart';
import '../../../../core/models/weather_model.dart';
import '../weather_widgets/cloudy_widget.dart';
import '../weather_widgets/misty_widget.dart';
import '../weather_widgets/rainy_widget.dart';
import '../weather_widgets/snowy_widget.dart';
import '../weather_widgets/stormy_widget.dart';
import '../weather_model_widget.dart';

/// 天気の詳細情報を表示する画面ウィジェット
class WeatherDetailView extends StatelessWidget {
  /// 表示対象の天気データ
  final WeatherModel model;

  /// 天気の詳細情報を表示する画面ウィジェットを生成する
  ///
  /// [model] 表示する天気データ
  const WeatherDetailView({super.key, required this.model});

  /// 天気種別と昼夜に応じた背景ウィジェットを返す
  ///
  /// 各天気ウィジェットが昼夜で背景色を切り替えます。
  Widget _getWeatherWidget(WeatherType type) {
    final bool night = isNightTime();
    return switch (type) {
      WeatherType.clear => night ? const NightWidget() : const SunnyWidget(),
      WeatherType.clouds => CloudyWidget(isNight: night),
      WeatherType.rain => RainyWidget(isNight: night),
      WeatherType.drizzle => RainyWidget(isNight: night),
      WeatherType.thunderstorm => StormyWidget(isNight: night),
      WeatherType.snow => SnowyWidget(isNight: night),
      _ => MistyWidget(isNight: night),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(model.weatherType.label)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _getWeatherWidget(model.weatherType),
          Center(child: WeatherModelWidget(model: model)),
        ],
      ),
    );
  }
}
