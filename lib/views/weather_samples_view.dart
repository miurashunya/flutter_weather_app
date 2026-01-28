import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';
import '../models/weather_model.dart';
import 'weather_detail_view.dart';

class WeatherSamplesView extends StatelessWidget {
  const WeatherSamplesView({super.key});

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
    final values = WeatherType.values;
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Samples')),
      body: ListView.builder(
        itemCount: values.length,
        itemBuilder: (context, index) {
          final type = values[index];
          final scene = _mapToScene(type);
          return InkWell(
            onTap: () {
              final model = WeatherModel(
                weatherType: type,
                description: type.label,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WeatherDetailView(model: model),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // background scene
                    scene.sceneWidget,
                    // overlay label
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              type.name,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
