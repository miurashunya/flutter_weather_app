import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_animation/weather_animation.dart';
import '../models/weather_model.dart';
import '../viewmodels/weather_view_model.dart';
import 'weather_samples_view.dart';
import 'cloudy_widget.dart';
import 'weather_model_widget.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  bool _initialized = false;

  WeatherScene _mapToScene(WeatherType type) {
    // Map our WeatherType to a WeatherScene provided by weather_animation.
    switch (type) {
      case WeatherType.clear:
        return WeatherScene.scorchingSun;
      case WeatherType.clouds:
        return WeatherScene.sunset;
      case WeatherType.rain:
      case WeatherType.drizzle:
        return WeatherScene.rainyOvercast;
      case WeatherType.thunderstorm:
        return WeatherScene.stormy;
      case WeatherType.snow:
        return WeatherScene.snowfall;
      case WeatherType.mist:
      case WeatherType.fog:
        return WeatherScene.weatherEvery;
      default:
        return WeatherScene.weatherEvery;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        // アプリ起動時に自動で天気を取得
        ref.read(weatherViewModelProvider.notifier).fetchWeather();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherViewModelProvider);

    final WeatherType? type = state.weather?.weatherType;
    final bool hasWeather = state.weather != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: null,
        actions: [
          // デバッグ時のみ表示
          if (!kReleaseMode)
            IconButton(
              tooltip: 'Samples',
              color: Colors.white,
              icon: const Icon(Icons.view_column),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WeatherSamplesView()),
                );
              },
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background: 曇りは専用ウィジェット（グラデ+白い雲）を使う
          if (type != null)
            (type == WeatherType.clouds)
                ? const CloudyWidget()
                : _mapToScene(type).sceneWidget
          else
            const SizedBox.shrink(),
          // Foreground content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isLoading) ...[
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 12),
                  const Text('取得中...', style: TextStyle(color: Colors.white)),
                ] else if (state.error != null) ...[
                  Icon(Icons.error, color: Colors.red[700], size: 48),
                  const SizedBox(height: 8),
                  Text(state.error ?? ''),
                ] else if (hasWeather) ...[
                  WeatherModelWidget(model: state.weather!),
                ] else ...[
                  const Text('ボタンを押して現在の天気を取得してください'),
                ],
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed:
            () => ref.read(weatherViewModelProvider.notifier).fetchWeather(),
        tooltip: '天気更新',
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder:
              (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
          child:
              state.isLoading
                  ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.8,
                      // 初回以外は色を変える
                      valueColor: AlwaysStoppedAnimation(Colors.black87),
                    ),
                  )
                  : const Icon(
                    Icons.autorenew_rounded,
                    key: ValueKey('icon'),
                    color: Colors.black87,
                  ),
        ),
      ),
    );
  }
}
