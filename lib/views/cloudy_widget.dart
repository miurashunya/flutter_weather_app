import 'package:flutter/material.dart';
import 'package:weather_animation/weather_animation.dart';

class CloudyWidget extends StatelessWidget {
  /// 背景グラデーションと白い雲のアニメーションを表示するウィジェット
  const CloudyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return WrapperScene(
      colors: [Color(0xFF616161), Color.fromARGB(255, 99, 98, 98)],
      children: [
        const CloudWidget(
          cloudConfig: CloudConfig(
            size: 250.0,
            color: Color.fromARGB(100, 231, 231, 231),
            icon: IconData(63056, fontFamily: 'MaterialIcons'),
            widgetCloud: null,
            x: 20.0,
            y: 35.0,
            scaleBegin: 1.0,
            scaleEnd: 1.08,
            scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
            slideX: 20.0,
            slideY: 0.0,
            slideDurMill: 3000,
            slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
          ),
        ),
        const CloudWidget(
          cloudConfig: CloudConfig(
            size: 160.0,
            color: Color.fromARGB(100, 231, 231, 231),
            icon: IconData(63056, fontFamily: 'MaterialIcons'),
            widgetCloud: null,
            x: 140.0,
            y: 130.0,
            scaleBegin: 1.0,
            scaleEnd: 1.1,
            scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
            slideX: 20.0,
            slideY: 4.0,
            slideDurMill: 2000,
            slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
          ),
        ),
      ],
    );
  }
}
