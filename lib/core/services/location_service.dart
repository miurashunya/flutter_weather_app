import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

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

/// [LocationService] を提供するプロバイダーです。
///
/// - `autoDispose` を使用しており、利用されなくなったら自動的に解放されます。
/// - テストでは `ProviderScope(overrides: [locationServiceProvider.overrideWithValue(...)])`
///   のようにオーバーライドしてモックを注入できます。
final locationServiceProvider = Provider.autoDispose(
  (ref) => LocationService(),
);

/// 位置情報を取得するサービスクラス
class LocationService {
  /// 現在の端末位置を取得する
  ///
  /// 位置情報の権限がない場合は [Exception] をスローします。
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

  /// 緯度・経度から住所情報（[geo.Placemark]）を取得する
  ///
  /// [latitude] 緯度, [longitude] 経度
  /// 該当する住所が見つからない場合は [StateError] をスローします。
  Future<geo.Placemark> getPlacemark(double latitude, double longitude) async {
    final placemarks = await geo.placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) {
      throw StateError(
        '座標 ($latitude, $longitude) に対応する住所が見つかりませんでした',
      );
    }
    return placemarks.first;
  }
}
