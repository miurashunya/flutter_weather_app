import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';

/// 雨・霧雨天気の背景アニメーションウィジェット
///
/// [isNight] が true の場合は暗い紺色系の背景に変更します。
class RainyWidget extends StatelessWidget {
  /// 雨・霧雨天気の背景アニメーションウィジェットを生成する
  ///
  /// [isNight] 夜モードにする場合は true
  const RainyWidget({super.key, this.isNight = false});

  /// 夜モードフラグ
  final bool isNight;

  /// 夜の背景色（暗いスレートブルー）
  static const List<Color> _nightColors = [
    Color(0xFF1A1F2E),
    Color(0xFF2D3A4A),
  ];

  @override
  Widget build(BuildContext context) {
    return WrapperScene.weather(
      scene: WeatherScene.rainyOvercast,
      // 夜は暗い紺色に、昼はデフォルト色（グレー系）
      colors: isNight ? _nightColors : null,
    );
  }
}
