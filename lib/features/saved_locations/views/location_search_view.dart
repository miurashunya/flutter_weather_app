import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/location_search_view_model.dart';

/// 地名検索・追加画面ウィジェット
class LocationSearchView extends ConsumerStatefulWidget {
  /// 地名検索・追加画面ウィジェットを生成する
  const LocationSearchView({super.key});

  @override
  ConsumerState<LocationSearchView> createState() => _LocationSearchViewState();
}

class _LocationSearchViewState extends ConsumerState<LocationSearchView> {
  /// 検索テキストフィールドのコントローラー
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 検索を実行する
  void _search() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    // フォーカスを外してキーボードを閉じる
    FocusScope.of(context).unfocus();
    ref.read(locationSearchViewModelProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationSearchViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('地域を追加')),
      body: Column(
        children: [
          // 検索入力エリア
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '地名を入力（例: 東京、大阪府）',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: const Text('検索'),
                ),
              ],
            ),
          ),
          // 検索結果エリア
          Expanded(
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  // 検索中はインジケーターを表示
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  // エラーメッセージを表示
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.error!,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (state.results.isEmpty) {
                  // 検索前または結果なし
                  return const Center(
                    child: Text('地名を入力して検索してください'),
                  );
                }
                // 検索結果一覧
                return ListView.builder(
                  itemCount: state.results.length,
                  itemBuilder: (context, index) {
                    final location = state.results[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(location.name),
                      subtitle: Text(
                        '緯度: ${location.latitude.toStringAsFixed(4)}, '
                        '経度: ${location.longitude.toStringAsFixed(4)}',
                      ),
                      onTap: () async {
                        // 地域を保存して前の画面に戻る
                        await ref
                            .read(locationSearchViewModelProvider.notifier)
                            .addLocation(location);
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
