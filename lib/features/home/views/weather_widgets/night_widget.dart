import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:weather_animation/weather_animation.dart';

/// 晴れ夜の背景アニメーションウィジェット
///
/// 深い紺色の背景に、またたく星と三日月を表示します。
class NightWidget extends StatelessWidget {
  /// 晴れ夜の背景アニメーションウィジェットを生成する
  const NightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const WrapperScene(
      // 夜空の深い紺色グラデーション
      colors: [Color(0xFF0A0E27), Color(0xFF0D1B4B)],
      children: [
        // またたく星（背景レイヤー）
        _StarsWidget(),
        // 三日月
        _MoonWidget(),
      ],
    );
  }
}

// ─── 三日月 ────────────────────────────────────────────────

/// 三日月ウィジェット
class _MoonWidget extends StatelessWidget {
  /// 三日月ウィジェットを生成する
  const _MoonWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MoonPainter());
  }
}

/// 三日月を描画するペインター
///
/// 左上角付近に saveLayer + BlendMode.clear で三日月形状を描画します。
class _MoonPainter extends CustomPainter {
  /// 三日月を描画するペインターを生成する
  const _MoonPainter();

  /// 月の中心位置（350x540 キャンバス座標）
  static const Offset _center = Offset(85, 80);

  /// 月の半径
  static const double _radius = 52.0;

  /// 影の円のオフセット（三日月の形を作る）
  static const Offset _shadowOffset = Offset(24, -5);

  /// 影の円の半径
  static const double _shadowRadius = _radius * 0.88;

  /// 月の色（薄い黄色）
  static const Color _moonColor = Color(0xFFFFF9C4);

  @override
  void paint(Canvas canvas, Size size) {
    // 月の淡いグロー効果
    canvas.drawCircle(
      _center,
      _radius + 20,
      Paint()
        ..color = const Color(0x25FFF9C4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // saveLayer で三日月形状を合成（両円が収まる十分な範囲を確保）
    canvas.saveLayer(const Rect.fromLTWH(0, 0, 220, 200), Paint());

    // 月の本体（満月）
    canvas.drawCircle(_center, _radius, Paint()..color = _moonColor);

    // 影の円を切り抜いて三日月に変形
    canvas.drawCircle(
      _center + _shadowOffset,
      _shadowRadius,
      Paint()..blendMode = BlendMode.clear,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── 星 ───────────────────────────────────────────────────

/// 各星のデータ
class _StarData {
  /// 各星のデータを生成する
  ///
  /// [x] X座標（350x540 キャンバス座標）
  /// [y] Y座標
  /// [radius] 星の半径
  /// [phase] またたきの初期位相（0〜2π）
  /// [speed] またたきの角速度（rad/s）
  /// [minOpacity] またたきの最小不透明度
  const _StarData({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.speed,
    required this.minOpacity,
  });

  final double x;
  final double y;
  final double radius;
  final double phase;
  final double speed;
  final double minOpacity;
}

/// またたく星のアニメーションウィジェット
///
/// Ticker で経過時間を単調増加させ、各星が独立したタイミングでまたたきます。
class _StarsWidget extends StatefulWidget {
  /// またたく星のアニメーションウィジェットを生成する
  const _StarsWidget();

  @override
  State<_StarsWidget> createState() => _StarsWidgetState();
}

class _StarsWidgetState extends State<_StarsWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// 起動からの経過秒数（単調増加・リセットなし）
  double _elapsedSeconds = 0;

  /// 星のデータリスト
  late final List<_StarData> _stars;

  /// 星の総数
  static const int _starCount = 70;

  @override
  void initState() {
    super.initState();
    final random = Random();
    // 星のデータを起動時1回のみ生成
    _stars = List.generate(_starCount, (_) {
      return _StarData(
        x: random.nextDouble() * 350,
        y: random.nextDouble() * 540,
        radius: 0.8 + random.nextDouble() * 2.2,
        phase: random.nextDouble() * 2 * pi,
        speed: 0.5 + random.nextDouble() * 2.5,
        minOpacity: 0.15 + random.nextDouble() * 0.35,
      );
    });

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
      painter: _StarsPainter(
        stars: _stars,
        elapsedSeconds: _elapsedSeconds,
      ),
    );
  }
}

/// 星を描画するペインター
///
/// [elapsedSeconds] に基づき各星の不透明度を変化させてまたたきを表現します。
class _StarsPainter extends CustomPainter {
  /// 星を描画するペインターを生成する
  ///
  /// [stars] 星のデータリスト
  /// [elapsedSeconds] 起動からの経過秒数（単調増加）
  const _StarsPainter({
    required this.stars,
    required this.elapsedSeconds,
  });

  final List<_StarData> stars;
  final double elapsedSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      // sin で不透明度を minOpacity〜1.0 の範囲で変化させる
      final double t =
          (sin(elapsedSeconds * star.speed + star.phase) + 1) / 2;
      final double opacity = star.minOpacity + (1.0 - star.minOpacity) * t;

      paint.color = Color.fromRGBO(255, 255, 255, opacity);
      canvas.drawCircle(Offset(star.x, star.y), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter oldDelegate) =>
      oldDelegate.elapsedSeconds != elapsedSeconds;
}
