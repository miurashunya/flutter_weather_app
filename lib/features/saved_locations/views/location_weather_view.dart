import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/saved_location.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/utils/weather_type_extension.dart';
import '../viewmodels/location_weather_view_model.dart';
import '../../home/views/cloudy_widget.dart';
import '../../home/views/weather_model_widget.dart';

/// 特定地域の天気を表示する画面ウィジェット
class LocationWeatherView extends ConsumerStatefulWidget {
  /// 表示対象の保存済み地域
  final SavedLocation location;

  /// 特定地域の天気を表示する画面ウィジェットを生成する
  const LocationWeatherView({super.key, required this.location});

  @override
  ConsumerState<LocationWeatherView> createState() =>
      _LocationWeatherViewState();
}

class _LocationWeatherViewState extends ConsumerState<LocationWeatherView> {
  @override
  void initState() {
    super.initState();
    // 画面表示時に天気を取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(locationWeatherViewModelProvider(widget.location).notifier)
          .fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      locationWeatherViewModelProvider(widget.location),
    );

    final WeatherType? type = state.weather?.weatherType;
    final bool hasWeather = state.weather != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 地域名をタイトルに表示
        title: Text(
          widget.location.name,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 天気更新ボタン
          IconButton(
            icon: const Icon(Icons.autorenew_rounded),
            tooltip: '天気更新',
            onPressed:
                () => ref
                    .read(
                      locationWeatherViewModelProvider(widget.location).notifier,
                    )
                    .fetchWeather(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景: 天気タイプに応じたアニメーションシーン
          if (type != null)
            (type == WeatherType.clouds)
                ? const CloudyWidget()
                : type.toScene().sceneWidget
          else
            const SizedBox.shrink(),
          // コンテンツオーバーレイ
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isLoading) ...[
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    '取得中...',
                    style: TextStyle(color: Colors.white),
                  ),
                ] else if (state.error != null) ...[
                  Icon(Icons.error, color: Colors.red[700], size: 48),
                  const SizedBox(height: 8),
                  Text(
                    state.error ?? '',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ] else if (hasWeather) ...[
                  WeatherModelWidget(
                    model: state.weather!,
                    locationName: state.locationName,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
