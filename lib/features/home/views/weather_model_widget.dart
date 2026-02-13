import 'package:flutter/material.dart';
import '../../../core/models/weather_model.dart';

/// 天気モデルを表示するウィジェット
class WeatherModelWidget extends StatelessWidget {
  final WeatherModel model;

  /// 表示する地名（県・市）。null の場合は非表示
  final String? locationName;

  /// 天気モデルを表示するウィジェット
  const WeatherModelWidget({super.key, required this.model, this.locationName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 温度がnullでない場合のみ表示
        if (model.temperature != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${model.temperature!.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black45,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '°C',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black45,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        const SizedBox(height: 12),
        // 天気の名称
        Text(
          model.weatherType.label,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: Colors.white,
            shadows: const [
              Shadow(
                blurRadius: 6,
                color: Colors.black45,
                offset: Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // 天気の説明（nullでない場合のみ表示）
        if (model.description != null)
          Text(
            model.description!,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        // 地名（県・市）の表示
        if (locationName != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(
                locationName!,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
