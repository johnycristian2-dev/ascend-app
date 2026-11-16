import 'package:geolocator/geolocator.dart';
import '../geo/gpx_parser.dart';

/// Uma leitura de GPS.
class LocationFix {
  final GeoPoint point;
  final double accuracyM;
  const LocationFix(this.point, this.accuracyM);
}

/// Fina camada sobre o plugin de localização — ninguém fora daqui fala
/// com o `geolocator`. Na web, usa a geolocalização do navegador (exige
/// https ou localhost e a permissão do usuário).
class LocationService {
  /// Pede permissão. Devolve null se estiver tudo certo, ou o motivo.
  Future<String?> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'A localização do aparelho está desligada.';
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) return 'Permissão de localização negada.';
    if (perm == LocationPermission.deniedForever) {
      return 'Permissão de localização bloqueada — libere nas configurações.';
    }
    return null;
  }

  Stream<LocationFix> fixes() => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).map((p) => LocationFix(GeoPoint(p.latitude, p.longitude), p.accuracy));
}
