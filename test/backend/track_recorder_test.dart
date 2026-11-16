import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/backend/geo/gpx_parser.dart';
import 'package:ascend/backend/geo/track_recorder.dart';

// Pontos sintéticos só para testar a lógica — não são uma trilha real.
GeoPoint _p(double latOffsetM) => GeoPoint(-25.0 + latOffsetM / 111320, -48.0);

void main() {
  test('ignora leitura imprecisa e ponto parado; soma a distância', () {
    final r = TrackRecorder();
    expect(r.add(_p(0), accuracyM: 5), isTrue);
    expect(r.add(_p(3), accuracyM: 5), isFalse); // parado (< 8 m)
    expect(r.add(_p(100), accuracyM: 80), isFalse); // impreciso
    expect(r.add(_p(100), accuracyM: 5), isTrue);
    expect(r.add(_p(250), accuracyM: 5), isTrue);
    expect(r.points.length, 3);
    expect(r.km, closeTo(0.25, 0.005));
  });

  test('downsampled mantém primeiro e último e respeita o máximo', () {
    final r = TrackRecorder(minStepM: 1);
    for (var i = 0; i < 100; i++) {
      r.add(_p(i * 10.0));
    }
    final d = r.downsampled(10);
    expect(d.length, 10);
    expect(d.first, r.points.first);
    expect(d.last, r.points.last);
    expect(r.downsampled(500).length, r.points.length);
  });

  test('clear zera o traçado', () {
    final r = TrackRecorder()..add(_p(0))..add(_p(50));
    r.clear();
    expect(r.points, isEmpty);
    expect(r.km, 0);
  });
}
