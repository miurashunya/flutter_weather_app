import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';

/// 曇り天気の背景アニメーションウィジェット
///
/// [isNight] が true の場合は暗い紺色背景＋青みがかった雲を表示します。
/// false の場合はグレーのグラデーション背景に白い雲を表示します。
class CloudyWidget extends StatelessWidget {
  /// 曇り天気の背景アニメーションウィジェットを生成する
  ///
  /// [isNight] 夜モードにする場合は true
  const CloudyWidget({super.key, this.isNight = false});

  /// 夜モードフラグ
  final bool isNight;

  /// 昼の背景色
  static const List<Color> _dayColors = [Color(0xFF616161), Color(0xFF636262)];

  /// 夜の背景色（暗い紺色）
  static const List<Color> _nightColors = [
    Color(0xFF1B2845),
    Color(0xFF2D3E6B),
  ];

  /// 昼の雲の色
  static const Color _dayCloudColor = Color.fromARGB(100, 231, 231, 231);

  /// 夜の雲の色（青みがかった暗い雲）
  static const Color _nightCloudColor = Color.fromARGB(90, 170, 194, 235);

  @override
  Widget build(BuildContext context) {
    // 昼夜で背景色と雲の色を切り替える
    final colors = isNight ? _nightColors : _dayColors;
    final cloudColor = isNight ? _nightCloudColor : _dayCloudColor;

    return WrapperScene(
      colors: colors,
      children: [
        // 大きめの雲（左上）
        CloudWidget(
          cloudConfig: CloudConfig(
            size: 250.0,
            color: cloudColor,
            icon: const IconData(63056, fontFamily: 'MaterialIcons'),
            widgetCloud: null,
            x: 20.0,
            y: 35.0,
            scaleBegin: 1.0,
            scaleEnd: 1.08,
            scaleCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
            slideX: 20.0,
            slideY: 0.0,
            slideDurMill: 3000,
            slideCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
          ),
        ),
        // 小さめの雲（右下）
        CloudWidget(
          cloudConfig: CloudConfig(
            size: 160.0,
            color: cloudColor,
            icon: const IconData(63056, fontFamily: 'MaterialIcons'),
            widgetCloud: null,
            x: 140.0,
            y: 130.0,
            scaleBegin: 1.0,
            scaleEnd: 1.1,
            scaleCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
            slideX: 20.0,
            slideY: 4.0,
            slideDurMill: 2000,
            slideCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
          ),
        ),
      ],
    );
  }
}
