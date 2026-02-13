import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/saved_locations_view_model.dart';
import 'location_search_view.dart';
import 'location_weather_view.dart';

/// 保存済み地域一覧画面ウィジェット
class SavedLocationsView extends ConsumerStatefulWidget {
  /// 保存済み地域一覧画面ウィジェットを生成する
  const SavedLocationsView({super.key});

  @override
  ConsumerState<SavedLocationsView> createState() => _SavedLocationsViewState();
}

class _SavedLocationsViewState extends ConsumerState<SavedLocationsView> {
  @override
  void initState() {
    super.initState();
    // 画面表示時に保存地域を読み込む
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedLocationsViewModelProvider.notifier).load();
    });
  }

  /// 地域追加画面へ遷移し、戻り値に応じてリロードする
  Future<void> _navigateToSearch() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LocationSearchView()),
    );
    // 追加が完了した場合はリロード
    if (result == true && mounted) {
      ref.read(savedLocationsViewModelProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savedLocationsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('保存した地域')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSearch,
        tooltip: '地域を追加',
        child: const Icon(Icons.add),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            // 読み込み中はインジケーターを表示
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            // エラーメッセージを表示
            return Center(
              child: Text(
                state.error!,
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          }
          if (state.locations.isEmpty) {
            // 登録地域がない場合
            return const Center(child: Text('地域が登録されていません'));
          }
          // 保存済み地域のリスト
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: state.locations.length,
            itemBuilder: (context, index) {
              final location = state.locations[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(location.name),
                  // 削除ボタン
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: '削除',
                    onPressed: () {
                      ref
                          .read(savedLocationsViewModelProvider.notifier)
                          .delete(location.id);
                    },
                  ),
                  // 天気画面へ遷移
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LocationWeatherView(location: location),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
