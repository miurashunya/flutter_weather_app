import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'geocoding_service.dart';

/// 位置情報パーミッションが拒否された際にスローされる例外
class LocationPermissionDeniedException implements Exception {
  /// 永続的に拒否されているかどうか（`true` の場合は設定アプリからの変更が必要）
  final bool isPermanent;

  /// 位置情報パーミッション拒否例外を生成する
  const LocationPermissionDeniedException({this.isPermanent = false});

  @override
  String toString() => isPermanent
      ? '位置情報の権限が永続的に拒否されています。設定アプリから許可してください。'
      : '位置情報の権限が拒否されました';
}

/// [LocationService] を提供するプロバイダー
///
/// - `autoDispose` を使用しており、利用されなくなったら自動的に解放されます。
/// - テストでは `ProviderScope(overrides: [locationServiceProvider.overrideWithValue(...)])`
///   のようにオーバーライドしてモックを注入できます。
final locationServiceProvider = Provider.autoDispose(
  (ref) => LocationService(ref.watch(geocodingServiceProvider)),
);

/// 位置情報を取得するサービスクラス
class LocationService {
  final GeocodingService _geocodingService;

  /// [GeocodingService] を受け取って位置情報サービスを生成する
  const LocationService(this._geocodingService);

  /// 現在の端末位置を取得する
  ///
  /// 位置情報の権限がない場合は [LocationPermissionDeniedException] をスローします。
  Future<Position> getCurrentPosition() async {
    final permission = await Geolocator.requestPermission();
    // 永続的拒否：設定アプリからのみ変更可能
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedException(isPermanent: true);
    }
    // 一時的拒否：再度リクエスト可能
    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDeniedException();
    }
    return Geolocator.getCurrentPosition();
  }

  /// 緯度・経度から地名を取得する
  ///
  /// [latitude] 緯度, [longitude] 経度
  /// 取得できない場合は null を返します。
  Future<String?> getLocationName(double latitude, double longitude) {
    return _geocodingService.getPlaceName(latitude, longitude);
  }
}
