import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/utils/weather_type_extension.dart';
import '../viewmodels/weather_view_model.dart';
import '../../saved_locations/views/saved_locations_view.dart';
import 'weather_samples_view.dart';
import 'cloudy_widget.dart';
import 'sunny_widget.dart';
import 'weather_model_widget.dart';

/// ホーム画面ウィジェット
class HomeView extends ConsumerStatefulWidget {
  /// ホーム画面ウィジェットを生成する
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    // アプリ起動時に自動で天気を取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherViewModelProvider.notifier).fetchWeather();
    });
  }

  /// 天気種別に応じた背景ウィジェットを返す
  Widget _getWeatherWidget(WeatherType type) {
    return switch (type) {
      WeatherType.clear => const SunnyWidget(),
      WeatherType.clouds => const CloudyWidget(),
      _ => type.toScene().sceneWidget,
    };
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
          // 保存済み地域一覧への遷移ボタン
          IconButton(
            icon: const Icon(Icons.list_alt),
            iconSize: 36,
            color: Colors.white,
            tooltip: '保存した地域',
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SavedLocationsView()),
                ),
          ),
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
          // 背景: 晴れは専用ウィジェット（水色背景+単色太陽）、
          // 曇りは専用ウィジェット（グラデ+白い雲）、それ以外はアニメーションシーン
          type != null ? _getWeatherWidget(type) : const SizedBox.shrink(),
          // コンテンツオーバーレイ
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
                  // 永続的なパーミッション拒否の場合は設定アプリへ誘導
                  // Web は openAppSettings() 非対応のため表示しない
                  if (state.isPermissionPermanentlyDenied && !kIsWeb) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Geolocator.openAppSettings(),
                      icon: const Icon(Icons.settings),
                      label: const Text('設定を開く'),
                    ),
                  ],
                ] else if (hasWeather) ...[
                  WeatherModelWidget(
                    model: state.weather!,
                    locationName: state.locationName,
                  ),
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
