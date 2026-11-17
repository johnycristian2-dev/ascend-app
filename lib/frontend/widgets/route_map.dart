import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../backend/geo/gpx_parser.dart';
import '../theme/app_colors.dart';
import 'app_label.dart';

/// Mapa real (OpenStreetMap) que substitui a silhueta de relevo desenhada.
///
/// Usa flutter_map + tiles públicos do OpenStreetMap em vez do Google Maps
/// originalmente planejado: não exige chave de API nem conta no Google Cloud,
/// então funciona assim que o pacote é baixado — importante para não travar
/// numa aprovação/configuração externa pendente.
class RouteMap extends StatefulWidget {
  final String labelTopLeft;
  final String labelBottomRight;
  final Color labelBottomRightColor;
  final double height;

  /// GPX real da rota, em `assets/routes/` (ver README). Se o arquivo não
  /// existir, o mapa segue só com o marcador do cume — nunca um traçado
  /// inventado.
  final String? trackAsset;

  /// Local da trilha em curso (cume). Nulo = sem localização cadastrada:
  /// o mapa mostra o Brasil e avisa, em vez de chutar um lugar.
  final ll.LatLng? center;

  /// Traçado gravado pelo GPS do usuário (verde) e sua posição agora.
  final List<ll.LatLng> recorded;
  final ll.LatLng? me;

  /// Traçado GPX que o usuário importou para esta trilha (âmbar). Tem
  /// prioridade sobre o arquivo de `trackAsset`.
  final List<ll.LatLng> track;

  /// O ponto `center` é só a região da trilha, não o cume exato.
  final bool aprox;

  /// Modo "escolher no mapa": toque define `picked` e chama [onPick].
  final ValueChanged<ll.LatLng>? onPick;
  final ll.LatLng? picked;

  /// Mostra o aviso "sem localização" quando `center` é nulo.
  final bool avisarSemLocal;

  const RouteMap({
    super.key,
    required this.labelTopLeft,
    required this.labelBottomRight,
    required this.labelBottomRightColor,
    this.height = 170,
    this.trackAsset,
    this.center,
    this.recorded = const [],
    this.me,
    this.track = const [],
    this.aprox = false,
    this.onPick,
    this.picked,
    this.avisarSemLocal = true,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  List<ll.LatLng> _track = const [];
  double _km = 0;
  final _ctrl = MapController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(RouteMap old) {
    super.didUpdateWidget(old);
    if (widget.trackAsset != old.trackAsset) {
      _track = const [];
      _km = 0;
      _load();
    }
    final me = widget.me;
    if (me != null && me != old.me) {
      // Segue o usuário. Se o mapa ainda não está pronto, ignora.
      try {
        _ctrl.move(me, _ctrl.camera.zoom < 15 ? 15 : _ctrl.camera.zoom);
      } catch (_) {}
    }
  }

  Future<void> _load() async {
    final asset = widget.trackAsset;
    if (asset == null) return;
    try {
      final pts = parseGpx(await rootBundle.loadString(asset));
      if (!mounted || pts.length < 2) return;
      setState(() {
        _track = [for (final p in pts) ll.LatLng(p.lat, p.lon)];
        _km = trackLengthKm(pts);
      });
    } catch (_) {
      // Sem GPX no pacote: mapa sem traçado.
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final line = w.track.length >= 2 ? w.track : _track;
    final km = w.track.length >= 2
        ? trackLengthKm([for (final p in w.track) GeoPoint(p.latitude, p.longitude)])
        : _km;
    final hasTrack = line.length >= 2;
    final center = w.center;
    final toSummitKm = (w.me != null && center != null)
        ? distanceKmBetween(GeoPoint(w.me!.latitude, w.me!.longitude),
            GeoPoint(center.latitude, center.longitude))
        : null;
    return Container(
      height: w.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border.all(color: AppColors.border),
        borderRadius: r4,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              key: ValueKey('${line.length}-${center?.latitude}-${center?.longitude}'),
              mapController: _ctrl,
              options: MapOptions(
                initialCenter: center ?? const ll.LatLng(-14, -52),
                initialZoom: center == null ? 3.5 : 12.5,
                minZoom: center == null ? 3 : 9,
                maxZoom: 17,
                onTap: w.onPick == null ? null : (_, p) => w.onPick!(p),
                initialCameraFit: hasTrack
                    ? CameraFit.bounds(
                        bounds: LatLngBounds.fromPoints(line),
                        padding: const EdgeInsets.all(28),
                        maxZoom: 16,
                      )
                    : null,
              ),
              children: [
                // Tonalizado para combinar com o tema escuro do app — os
                // tiles originais do OSM continuam claros por baixo.
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.30, 0, 0, 0, 10,
                    0, 0.32, 0, 0, 10,
                    0, 0, 0.34, 0, 14,
                    0, 0, 0, 1, 0,
                  ]),
                  child: TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ascend.app',
                    maxZoom: 19,
                  ),
                ),
                if (hasTrack)
                  PolylineLayer(polylines: [
                    Polyline(points: line, strokeWidth: 3.5, color: AppColors.amber),
                  ]),
                if (toSummitKm != null)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: [w.me!, center!],
                      strokeWidth: 2.5,
                      color: AppColors.blue,
                      pattern: StrokePattern.dashed(segments: const [7, 7]),
                    ),
                  ]),
                if (w.recorded.length >= 2)
                  PolylineLayer(polylines: [
                    Polyline(points: w.recorded, strokeWidth: 4, color: AppColors.green),
                  ]),
                MarkerLayer(
                  markers: [
                    if (w.me != null)
                      Marker(
                        point: w.me!,
                        width: 22,
                        height: 22,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    if (w.picked != null)
                      Marker(
                        point: w.picked!,
                        width: 34,
                        height: 34,
                        child: const Icon(Icons.location_on, color: AppColors.amber, size: 32),
                      ),
                    if (hasTrack)
                      Marker(
                        point: line.first,
                        width: 18,
                        height: 18,
                        child: const Icon(Icons.trip_origin, color: AppColors.green, size: 14),
                      ),
                    if (center != null)
                      Marker(
                        point: center,
                        width: 28,
                        height: 28,
                        child: const Icon(Icons.flag_rounded, color: AppColors.amber, size: 20),
                      ),
                  ],
                ),
                const RichAttributionWidget(
                  animationConfig: ScaleRAWA(),
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 11,
            top: 10,
            child: AppLabel(
                hasTrack
                    ? '${w.labelTopLeft} · TRAÇADO ${km.toStringAsFixed(1).replaceAll('.', ',')} KM'
                    : toSummitKm != null
                        ? '${w.labelTopLeft} · A ${toSummitKm.toStringAsFixed(1).replaceAll('.', ',')} KM DO PONTO'
                        : w.labelTopLeft,
                color: AppColors.dim,
                size: 8,
                tracking: 0.26),
          ),
          if (center != null && w.aprox)
            const Positioned(
              left: 11,
              top: 28,
              child: AppLabel('LOCAL APROXIMADO · REGIÃO DA TRILHA, NÃO O CUME EXATO',
                  color: AppColors.amber, size: 8, tracking: 0.12),
            ),
          if (center == null && w.avisarSemLocal)
            const Positioned(
              left: 11,
              top: 28,
              child: AppLabel('SEM LOCALIZAÇÃO CADASTRADA PARA ESTA TRILHA',
                  color: AppColors.amber, size: 8, tracking: 0.12),
            ),
          Positioned(
            right: 11,
            bottom: 34,
            child: AppLabel(w.labelBottomRight, color: w.labelBottomRightColor, size: 8, tracking: 0.16),
          ),
        ],
      ),
    );
  }
}
