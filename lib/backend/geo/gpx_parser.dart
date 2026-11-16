import 'dart:math' as math;

/// Ponto de um traçado (graus decimais). Dart puro — sem Flutter — para
/// poder ser testado isoladamente, como `expedition_calculator.dart`.
class GeoPoint {
  final double lat;
  final double lon;
  const GeoPoint(this.lat, this.lon);

  @override
  bool operator ==(Object other) => other is GeoPoint && other.lat == lat && other.lon == lon;
  @override
  int get hashCode => Object.hash(lat, lon);
}

final _trkpt = RegExp(r'<(?:trkpt|rtept)\b([^>]*)>', caseSensitive: false);
final _lat = RegExp(r'''\blat\s*=\s*["']([^"']+)["']''', caseSensitive: false);
final _lon = RegExp(r'''\blon\s*=\s*["']([^"']+)["']''', caseSensitive: false);

/// Extrai os pontos de um GPX (`<trkpt>`, ou `<rtept>` se não houver
/// trilha), na ordem do arquivo. Pontos com coordenada inválida ou fora
/// da faixa são descartados — nunca "consertados".
List<GeoPoint> parseGpx(String xml) {
  final out = <GeoPoint>[];
  for (final m in _trkpt.allMatches(xml)) {
    final attrs = m.group(1)!;
    final lat = double.tryParse(_lat.firstMatch(attrs)?.group(1) ?? '');
    final lon = double.tryParse(_lon.firstMatch(attrs)?.group(1) ?? '');
    if (lat == null || lon == null) continue;
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) continue;
    out.add(GeoPoint(lat, lon));
  }
  return out;
}

/// Distância total do traçado, em km (haversine ponto a ponto).
double trackLengthKm(List<GeoPoint> pts) {
  const r = 6371.0088;
  double rad(double d) => d * math.pi / 180;
  var total = 0.0;
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1], b = pts[i];
    final dLat = rad(b.lat - a.lat), dLon = rad(b.lon - a.lon);
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(a.lat)) * math.cos(rad(b.lat)) * math.pow(math.sin(dLon / 2), 2);
    total += 2 * r * math.asin(math.sqrt(h));
  }
  return total;
}
