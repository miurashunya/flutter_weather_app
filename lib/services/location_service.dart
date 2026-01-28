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

class LocationService {
  Future<Position> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<geo.Placemark> getPlacemark(double latitude, double longitude) async {
    final placemarks = await geo.placemarkFromCoordinates(latitude, longitude);
    return placemarks.first;
  }
}
