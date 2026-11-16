import 'gpx_parser.dart';

/// Grava o traçado de quem está subindo, a partir das leituras de GPS.
/// Dart puro (testável sem GPS). Descarta leitura imprecisa e ponto
/// parado, para o traçado não virar um borrão de ruído.
class TrackRecorder {
  /// Leituras com precisão pior que isso (m) são ignoradas.
  final double maxAccuracyM;

  /// Distância mínima (m) desde o último ponto gravado.
  final double minStepM;

  final List<GeoPoint> points = [];
  double km = 0;

  TrackRecorder({this.maxAccuracyM = 50, this.minStepM = 8});

  /// Devolve true se o ponto entrou no traçado.
  bool add(GeoPoint p, {double accuracyM = 0}) {
    if (accuracyM > maxAccuracyM) return false;
    if (points.isEmpty) {
      points.add(p);
      return true;
    }
    final d = distanceKmBetween(points.last, p);
    if (d * 1000 < minStepM) return false;
    km += d;
    points.add(p);
    return true;
  }

  void clear() {
    points.clear();
    km = 0;
  }

  /// No máximo [max] pontos, mantendo o primeiro e o último — para caber
  /// no caderno do Firestore.
  List<GeoPoint> downsampled(int max) {
    if (points.length <= max || max < 2) return List.of(points);
    final out = <GeoPoint>[];
    for (var i = 0; i < max; i++) {
      out.add(points[(i * (points.length - 1) / (max - 1)).round()]);
    }
    return out;
  }
}
