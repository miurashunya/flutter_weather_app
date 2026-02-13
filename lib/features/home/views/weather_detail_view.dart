import 'package:flutter/material.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/utils/weather_type_extension.dart';
import 'cloudy_widget.dart';
import 'weather_model_widget.dart';

/// 天気の詳細情報を表示する画面ウィジェット
class WeatherDetailView extends StatelessWidget {
  /// 表示対象の天気データ
  final WeatherModel model;

  /// 天気の詳細情報を表示する画面ウィジェットを生成する
  ///
  /// [model] 表示する天気データ
  const WeatherDetailView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(model.weatherType.label)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 曇りは専用ウィジェット、それ以外はアニメーションシーン
          if (model.weatherType == WeatherType.clouds)
            const CloudyWidget()
          else
            model.weatherType.toScene().sceneWidget,
          Center(child: WeatherModelWidget(model: model)),
        ],
      ),
    );
  }
}
