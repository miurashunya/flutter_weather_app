import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_location.dart';

/// [SavedLocationsService] を提供するプロバイダー
final savedLocationsServiceProvider = Provider.autoDispose(
  (ref) => SavedLocationsService(),
);

/// 保存済み地域のCRUD操作を行うサービスクラス
class SavedLocationsService {
  /// SharedPreferencesのキー
  static const _key = 'saved_locations';

  /// 保存済み地域をすべて読み込む
  ///
  /// 返り値: 保存済み地域のリスト
  Future<List<SavedLocation>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    // データが存在しない場合は空リストを返す
    if (jsonString == null) return [];

    final list = jsonDecode(jsonString) as List<dynamic>;
    // JSONリストを [SavedLocation] のリストに変換
    return list
        .map((e) => SavedLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 地域を追加して保存する
  ///
  /// [location] 追加する地域情報
  Future<void> save(SavedLocation location) async {
    final all = await loadAll();
    // 既存リストに追加
    all.add(location);
    await _persist(all);
  }

  /// 指定したIDの地域を削除して保存する
  ///
  /// [id] 削除対象の地域ID
  Future<void> delete(String id) async {
    final all = await loadAll();
    // 対象IDを除いたリストに更新
    all.removeWhere((loc) => loc.id == id);
    await _persist(all);
  }

  /// 地域リストをSharedPreferencesに書き込む
  ///
  /// [locations] 保存する地域リスト
  Future<void> _persist(List<SavedLocation> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      locations.map((loc) => loc.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }
}
