import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../theme/app_colors.dart';
import 'app_label.dart';

/// Cume do Pico Paraná (Serra do Marumbi, PR). Fonte: mountain-forecast.com,
/// 25.25° S 48.81° W — é a coordenada real do cume, não ainda um traçado GPS
/// real da rota (isso exige registrar o track em campo; ver README/roteiro).
const picoParanaCenter = ll.LatLng(-25.25, -48.81);

/// Mapa real (OpenStreetMap) que substitui a silhueta de relevo desenhada.
///
/// Usa flutter_map + tiles públicos do OpenStreetMap em vez do Google Maps
/// originalmente planejado: não exige chave de API nem conta no Google Cloud,
/// então funciona assim que o pacote é baixado — importante para não travar
/// numa aprovação/configuração externa pendente.
class RouteMap extends StatelessWidget {
  final String labelTopLeft;
  final String labelBottomRight;
  final Color labelBottomRightColor;
  final double height;

  const RouteMap({
    super.key,
    required this.labelTopLeft,
    required this.labelBottomRight,
    required this.labelBottomRightColor,
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
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
              options: const MapOptions(
                initialCenter: picoParanaCenter,
                initialZoom: 12.5,
                minZoom: 9,
                maxZoom: 17,
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
                const MarkerLayer(
                  markers: [
                    Marker(
                      point: picoParanaCenter,
                      width: 28,
                      height: 28,
                      child: Icon(Icons.flag_rounded, color: AppColors.amber, size: 20),
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
            child: AppLabel(labelTopLeft, color: AppColors.dim, size: 8, tracking: 0.26),
          ),
          Positioned(
            right: 11,
            bottom: 34,
            child: AppLabel(labelBottomRight, color: labelBottomRightColor, size: 8, tracking: 0.16),
          ),
        ],
      ),
    );
  }
}
