import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:http/http.dart' as http;

/// [GeocodingService] を提供するプロバイダー
final geocodingServiceProvider = Provider.autoDispose(
  (ref) => GeocodingService(),
);

/// ジオコーディング結果を表すデータクラス
class GeocodingResult {
  /// 表示名（日本語対応）
  final String name;

  /// 緯度
  final double latitude;

  /// 経度
  final double longitude;

  /// ジオコーディング結果を生成する
  const GeocodingResult({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

/// プラットフォームに応じてジオコーディング実装を切り替えるサービス
///
/// - Android / iOS / macOS: `geocoding` パッケージを使用（日本語の都道府県・市区町村を取得可能）
/// - Windows / Web: OpenWeatherMap Geocoding API（HTTP）を使用
class GeocodingService {
  static const _baseUrl = 'https://api.openweathermap.org/geo/1.0';

  String get _apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  /// `geocoding` パッケージが使用可能なプラットフォームかどうか
  ///
  /// Web は `dart:io` の Platform が使えないため kIsWeb で先に除外します。
  bool get _isNativeGeocodingSupported =>
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  /// 地名から座標リストを取得する（フォワードジオコーディング）
  ///
  /// OWM API を全プラットフォームで使用します。
  /// [query] 検索する地名文字列
  /// [limit] 取得する最大件数（デフォルト5件）
  Future<List<GeocodingResult>> searchLocations(
    String query, {
    int limit = 5,
  }) async {
    final uri = Uri.parse('$_baseUrl/direct').replace(
      queryParameters: {'q': query, 'limit': '$limit', 'appid': _apiKey},
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Geocoding API エラー: ${response.statusCode}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      // local_names.ja が存在する場合は日本語名を優先
      final localNames = map['local_names'] as Map<String, dynamic>?;
      final jaName = localNames?['ja'] as String?;
      final state = map['state'] as String?;
      final baseName = jaName ?? (map['name'] as String);
      // 日本語名がない場合のみ英語の state を前置
      final name =
          (state != null && jaName == null) ? '$state $baseName' : baseName;
      return GeocodingResult(
        name: name,
        latitude: (map['lat'] as num).toDouble(),
        longitude: (map['lon'] as num).toDouble(),
      );
    }).toList();
  }

  /// 座標から地名を取得する（リバースジオコーディング）
  ///
  /// Android・iOS・macOS では `geocoding` パッケージで日本語の都道府県・市区町村を取得します。
  /// Windows・Web では OWM API にフォールバックします。
  /// [lat] 緯度, [lon] 経度
  Future<String?> getPlaceName(double lat, double lon) async {
    if (_isNativeGeocodingSupported) {
      return _getPlaceNameNative(lat, lon);
    }
    return _getPlaceNameFromApi(lat, lon);
  }

  /// geocoding パッケージで地名を取得する（Android・iOS・macOS 用）
  Future<String?> _getPlaceNameNative(double lat, double lon) async {
    final placemarks = await geo.placemarkFromCoordinates(lat, lon);
    if (placemarks.isEmpty) return null;
    final pm = placemarks.first;
    // 都道府県（administrativeArea）と市区町村（locality）を組み合わせる
    final parts = [pm.administrativeArea, pm.locality]
        .where((s) => s != null && s.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.join(' ') : null;
  }

  /// OWM API で地名を取得する（Windows・Web 用フォールバック）
  Future<String?> _getPlaceNameFromApi(double lat, double lon) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(
      queryParameters: {
        'lat': '$lat',
        'lon': '$lon',
        'limit': '1',
        'appid': _apiKey,
      },
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) return null;

    final map = list.first as Map<String, dynamic>;
    // local_names.ja が存在する場合は日本語名を優先
    final localNames = map['local_names'] as Map<String, dynamic>?;
    final jaName = localNames?['ja'] as String?;
    final state = map['state'] as String?;
    final baseName = jaName ?? (map['name'] as String);
    return (state != null && jaName == null) ? '$state $baseName' : baseName;
  }
}
