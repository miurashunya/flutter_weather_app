import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';

/// 雷雨天気の背景アニメーションウィジェット
///
/// [isNight] が true の場合はほぼ黒に近い暗い背景に変更します。
class StormyWidget extends StatelessWidget {
  /// 雷雨天気の背景アニメーションウィジェットを生成する
  ///
  /// [isNight] 夜モードにする場合は true
  const StormyWidget({super.key, this.isNight = false});

  /// 夜モードフラグ
  final bool isNight;

  /// 夜の背景色（ほぼ黒に近い暗い嵐色）
  static const List<Color> _nightColors = [
    Color(0xFF0D1117),
    Color(0xFF1C2432),
  ];

  @override
  Widget build(BuildContext context) {
    return WrapperScene.weather(
      scene: WeatherScene.stormy,
      // 夜は漆黒に近い色に、昼はデフォルト色（暗いグレー系）
      colors: isNight ? _nightColors : null,
    );
  }
}
