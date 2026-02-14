import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';

/// 霧・靄などその他天気の背景アニメーションウィジェット
///
/// [isNight] が true の場合は暗い深夜ブルーの背景に変更します。
class MistyWidget extends StatelessWidget {
  /// 霧・靄などその他天気の背景アニメーションウィジェットを生成する
  ///
  /// [isNight] 夜モードにする場合は true
  const MistyWidget({super.key, this.isNight = false});

  /// 夜モードフラグ
  final bool isNight;

  /// 夜の背景色（深夜の暗いブルー）
  static const List<Color> _nightColors = [
    Color(0xFF0A1628),
    Color(0xFF152B4E),
  ];

  @override
  Widget build(BuildContext context) {
    return WrapperScene.weather(
      scene: WeatherScene.weatherEvery,
      // 夜は深夜ブルーに、昼はデフォルト色（明るい青系）
      colors: isNight ? _nightColors : null,
    );
  }
}
