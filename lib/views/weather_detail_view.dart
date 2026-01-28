import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';
import '../models/weather_model.dart';
import 'cloudy_widget.dart';
import 'weather_model_widget.dart';

class WeatherDetailView extends StatelessWidget {
  final WeatherModel model;
  const WeatherDetailView({super.key, required this.model});

  WeatherScene _mapToScene(WeatherType type) {
    switch (type) {
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
        return WeatherScene.weatherEvery;
      default:
        return WeatherScene.weatherEvery;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = _mapToScene(model.weatherType);
    return Scaffold(
      appBar: AppBar(title: Text(model.weatherType.label)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (model.weatherType == WeatherType.clouds)
            const CloudyWidget()
          else
            scene.sceneWidget,
          Center(child: WeatherModelWidget(model: model)),
        ],
      ),
    );
  }
}
