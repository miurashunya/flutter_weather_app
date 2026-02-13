import 'package:flutter/material.dart';
import '../../../core/models/weather_model.dart';
import '../../../core/utils/weather_type_extension.dart';
import 'weather_detail_view.dart';

/// 全天気種別のアニメーションプレビュー画面
class WeatherSamplesView extends StatelessWidget {
  /// 全天気種別のアニメーションプレビュー画面を生成する
  const WeatherSamplesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Samples')),
      body: ListView.builder(
        itemCount: WeatherType.values.length,
        itemBuilder: (context, index) {
          final type = WeatherType.values[index];
          // タップで詳細画面に遷移
          return _WeatherSampleCard(type: type);
        },
      ),
    );
  }
}

/// 天気種別ごとのプレビューカードウィジェット
class _WeatherSampleCard extends StatelessWidget {
  /// 表示対象の天気種別
  final WeatherType type;

  /// 天気種別ごとのプレビューカードウィジェットを生成する
  const _WeatherSampleCard({required this.type});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // サンプルデータで詳細画面を表示
        final model = WeatherModel(
          weatherType: type,
          description: type.label,
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WeatherDetailView(model: model),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 背景アニメーションシーン
              type.toScene().sceneWidget,
              // 天気種別ラベルのオーバーレイ
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.name,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
