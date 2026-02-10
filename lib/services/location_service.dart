import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

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
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('位置情報の権限が拒否されました');
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
