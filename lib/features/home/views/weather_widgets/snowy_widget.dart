import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';

/// 雪天気の背景アニメーションウィジェット
///
/// [isNight] が true の場合は暗い紺色の冬の夜空に変更します。
class SnowyWidget extends StatelessWidget {
  /// 雪天気の背景アニメーションウィジェットを生成する
  ///
  /// [isNight] 夜モードにする場合は true
  const SnowyWidget({super.key, this.isNight = false});

  /// 夜モードフラグ
  final bool isNight;

  /// 夜の背景色（暗い冬の夜空）
  static const List<Color> _nightColors = [
    Color(0xFF0D1B4B),
    Color(0xFF1A2A6E),
    Color(0xFF37474F),
  ];

  @override
  Widget build(BuildContext context) {
    return WrapperScene.weather(
      scene: WeatherScene.snowfall,
      // 夜は暗い紺色に、昼はデフォルト色（青〜ライトブルー〜グレー）
      colors: isNight ? _nightColors : null,
    );
  }
}
