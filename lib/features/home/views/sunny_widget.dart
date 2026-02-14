import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:weather_animation/weather_animation.dart';

/// 晴れ天気の背景アニメーションウィジェット
///
/// 水色（空色）のグラデーション背景に、単色の太陽と放射状の光線を表示します。
class SunnyWidget extends StatelessWidget {
  /// 晴れ天気の背景アニメーションウィジェットを生成する
  const SunnyWidget({super.key});

  /// 太陽の単色（温かみのある黄色）
  static const Color _sunColor = Color(0xFFFDD835);

  /// 太陽のコア半径（width=820 の場合: 820 * 1.2 / 7 ≈ 140）
  static const double _coreRadius = 140.0;

  @override
  Widget build(BuildContext context) {
    return WrapperScene(
      // 空の水色グラデーション（上部は深い青、下部は明るい水色）
      colors: const [Color(0xFF42A5F5), Color(0xFFB3E5FC)],
      isLeftCornerGradient: false,
      children: [
        // 放射状の光線（アニメーションあり・太陽の後ろに描画）
        _SunRaysWidget(color: _sunColor, coreRadius: _coreRadius),
        // 単色の太陽（コア1つだけ、中間・外側は透明）
        const SunWidget(
          sunConfig: SunConfig(
            width: 820.0,
            blurSigma: 2.0,
            blurStyle: BlurStyle.solid,
            isLeftLocation: true,
            coreColor: _sunColor,
            midColor: Color(0x00000000),
            outColor: Color(0x00000000),
            animMidMill: 2000,
            animOutMill: 2500,
          ),
        ),
      ],
    );
  }
}

/// 放射状の光線アニメーションウィジェット
///
/// 各光線がランダムな速度・位相で独立して伸縮し、不規則なアニメーションを表示します。
/// Ticker で経過秒数を単調増加させるため、ループリセットによる固まりが発生しません。
class _SunRaysWidget extends StatefulWidget {
  /// 放射状の光線アニメーションウィジェットを生成する
  ///
  /// [color] 光線の色
  /// [coreRadius] 太陽コアの半径（光線の開始位置）
  const _SunRaysWidget({required this.color, required this.coreRadius});

  final Color color;
  final double coreRadius;

  @override
  State<_SunRaysWidget> createState() => _SunRaysWidgetState();
}

class _SunRaysWidgetState extends State<_SunRaysWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// 起動からの経過秒数（単調増加・リセットなし）
  double _elapsedSeconds = 0;

  /// 各光線のランダムな初期位相（0〜2π）
  late final List<double> _phases;

  /// 各光線のランダムな角速度（rad/s）
  late final List<double> _angularSpeeds;

  @override
  void initState() {
    super.initState();
    final random = Random();
    // 光線ごとにランダムな位相・角速度を生成（起動時1回のみ）
    _phases = List.generate(
      _SunRaysPainter.rayCount,
      (_) => random.nextDouble() * 2 * pi,
    );
    _angularSpeeds = List.generate(
      _SunRaysPainter.rayCount,
      // 0.5〜2.5 rad/s → およそ 2.5秒〜12.5秒で1周期
      (_) => 0.5 + random.nextDouble() * 2.0,
    );

    // Ticker で経過時間を単調増加させる（リセットなし）
    _ticker = createTicker((elapsed) {
      setState(() {
        _elapsedSeconds = elapsed.inMilliseconds / 1000.0;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SunRaysPainter(
        color: widget.color,
        coreRadius: widget.coreRadius,
        elapsedSeconds: _elapsedSeconds,
        phases: _phases,
        angularSpeeds: _angularSpeeds,
      ),
    );
  }
}

/// 太陽の放射状光線を描画するペインター
///
/// 左上角 (0, 0) を中心に、8°〜82° の範囲で光線を描きます。
/// 各光線はランダムな角速度・位相で独立して伸縮します。
class _SunRaysPainter extends CustomPainter {
  /// 太陽の放射状光線を描画するペインターを生成する
  ///
  /// [color] 光線の色
  /// [coreRadius] 太陽コアの半径（光線の開始位置）
  /// [elapsedSeconds] 起動からの経過秒数（単調増加）
  /// [phases] 各光線のランダム初期位相リスト
  /// [angularSpeeds] 各光線のランダム角速度リスト（rad/s）
  const _SunRaysPainter({
    required this.color,
    required this.coreRadius,
    required this.elapsedSeconds,
    required this.phases,
    required this.angularSpeeds,
  });

  final Color color;
  final double coreRadius;
  final double elapsedSeconds;
  final List<double> phases;
  final List<double> angularSpeeds;

  /// 光線の本数（外部から参照できるよう public に定義）
  static const int rayCount = 6;

  /// 光線の開始角度（左端の余白）
  static const double _startDeg = 8.0;

  /// 光線の終了角度（下端の余白）
  static const double _endDeg = 82.0;

  /// 光線の基本長さ
  static const double _baseLength = 50.0;

  /// 伸縮する振れ幅
  static const double _amplitude = 25.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 8.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final double startRad = _startDeg * pi / 180;
    final double endRad = _endDeg * pi / 180;
    final double step = (endRad - startRad) / (rayCount - 1);

    for (int i = 0; i < rayCount; i++) {
      final double angle = startRad + step * i;

      // 経過秒数 × 角速度 + 初期位相 で各光線が独立して伸縮する
      final double lengthOffset =
          _amplitude * sin(elapsedSeconds * angularSpeeds[i] + phases[i]);
      final double innerR = coreRadius + 18.0;
      final double outerR = coreRadius + 18.0 + _baseLength + lengthOffset;

      canvas.drawLine(
        Offset(cos(angle) * innerR, sin(angle) * innerR),
        Offset(cos(angle) * outerR, sin(angle) * outerR),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SunRaysPainter oldDelegate) =>
      oldDelegate.elapsedSeconds != elapsedSeconds;
}
