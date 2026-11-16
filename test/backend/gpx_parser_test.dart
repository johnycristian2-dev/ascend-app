import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/backend/geo/gpx_parser.dart';

// GPX de teste só para a lógica do parser — NÃO é uma trilha real.
const _gpx = '''<?xml version="1.0"?>
<gpx version="1.1"><trk><trkseg>
  <trkpt lat="-25.0000" lon="-48.0000"><ele>10</ele></trkpt>
  <trkpt lon="-48.0000" lat="-24.9100"/>
  <trkpt lat="abc" lon="-48.0"/>
  <trkpt lat="95.0" lon="-48.0"/>
</trkseg></trk></gpx>''';

void main() {
  test('parseGpx lê pontos em qualquer ordem de atributos e descarta inválidos', () {
    final pts = parseGpx(_gpx);
    expect(pts, const [GeoPoint(-25.0, -48.0), GeoPoint(-24.91, -48.0)]);
  });

  test('trackLengthKm: 0,09° de latitude ≈ 10 km', () {
    final km = trackLengthKm(parseGpx(_gpx));
    expect(km, closeTo(10.0, 0.1));
  });

  test('sem pontos → lista vazia e 0 km', () {
    expect(parseGpx('<gpx></gpx>'), isEmpty);
    expect(trackLengthKm(const []), 0);
  });
}
