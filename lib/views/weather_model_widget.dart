import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherModelWidget extends StatelessWidget {
  final WeatherModel model;
  const WeatherModelWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        Text(
          model.description ?? '',
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
