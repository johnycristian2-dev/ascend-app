import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../app.dart';
import '../../backend/state/expedition_state.dart' show ranks;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/widgets.dart';

/// Publica uma trilha no catálogo da comunidade, em nome do usuário.
class PublishTrailScreen extends StatefulWidget {
  const PublishTrailScreen({super.key});

  @override
  State<PublishTrailScreen> createState() => _PublishTrailScreenState();
}

class _PublishTrailScreenState extends State<PublishTrailScreen> {
  final _nome = TextEditingController();
  final _km = TextEditingController();
  final _ganho = TextEditingController();
  final _duracao = TextEditingController();
  final _regiao = TextEditingController();
  final _nota = TextEditingController();
  int _rank = 0;
  bool _sending = false;
  bool _locating = false;
  double? _lat;
  double? _lon;
  ll.LatLng? _focus; // só muda quando a posição vem do GPS (move a câmera)
  String? _erro;

  @override
  void dispose() {
    for (final c in [_nome, _km, _ganho, _duracao, _regiao, _nota]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _useMyLocation(BuildContext c) async {
    final s = Expedition.readOf(c);
    s.locationError = null;
    setState(() => _locating = true);
    final p = await s.currentLocation();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (p != null) {
        _lat = p.lat;
        _lon = p.lon;
        _focus = ll.LatLng(p.lat, p.lon);
      }
    });
  }

  Future<void> _publish(BuildContext c) async {
    final s = Expedition.readOf(c);
    // Uma trilha sem lugar não leva a lugar nenhum no mapa: exige o ponto.
    if (_lat == null || _lon == null) {
      setState(() => _erro = 'Marque o local da trilha no mapa antes de publicar.');
      return;
    }
    setState(() {
      _erro = null;
      _sending = true;
    });
    final ok = await s.publishTrail(
      nome: _nome.text,
      rankIdx: _rank,
      km: double.tryParse(_km.text.replaceAll(',', '.')) ?? 0,
      ganhoM: int.tryParse(_ganho.text) ?? 0,
      duracao: _duracao.text,
      regiao: _regiao.text,
      nota: _nota.text,
      lat: _lat,
      lon: _lon,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) s.go('discover');
  }

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Column(
      children: [
        ScreenBar('PUBLICAR TRILHA', sub: 'aparece para toda a comunidade', onBack: () => s.go('discover')),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 26),
            children: [
              _Field(label: 'NOME DA TRILHA', controller: _nome),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Field(label: 'DISTÂNCIA (km)', controller: _km, number: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'DESNÍVEL (m)', controller: _ganho, number: true)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Field(label: 'DURAÇÃO (ex.: 1 dia)', controller: _duracao)),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'REGIÃO', controller: _regiao)),
                ],
              ),
              const SizedBox(height: 10),
              const AppLabel('RANK SUGERIDO', color: AppColors.dim, size: 9),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (var i = 0; i < ranks.length; i++) ...[
                    Expanded(
                      child: AppButton(ranks[i],
                          onTap: () => setState(() => _rank = i),
                          primary: _rank == i),
                    ),
                    if (i < ranks.length - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              _Field(label: 'O QUE QUEM VAI PRECISA SABER', controller: _nota, lines: 3),
              const SizedBox(height: 10),
              const AppLabel('LOCALIZAÇÃO · TOQUE NO MAPA PARA MARCAR O INÍCIO OU O CUME',
                  color: AppColors.dim, size: 9),
              const SizedBox(height: 6),
              RouteMap(
                height: 260,
                labelTopLeft: 'ESCOLHER LOCAL',
                labelBottomRight: _lat == null ? 'NENHUM PONTO' : 'PONTO MARCADO',
                labelBottomRightColor: _lat == null ? AppColors.amber : AppColors.green,
                center: _focus,
                avisarSemLocal: false,
                picked: _lat == null ? null : ll.LatLng(_lat!, _lon!),
                onPick: (p) => setState(() {
                  _lat = p.latitude;
                  _lon = p.longitude;
                  _erro = null;
                }),
              ),
              const SizedBox(height: 6),
              AppButton(_locating ? 'LENDO GPS…' : 'USAR MINHA POSIÇÃO ATUAL',
                  onTap: _locating ? null : () => _useMyLocation(c)),
              const SizedBox(height: 6),
              Text(
                _lat != null
                    ? 'Local marcado: ${_lat!.toStringAsFixed(5)}, ${_lon!.toStringAsFixed(5)}'
                    : (s.locationError ?? 'Sem ponto marcado: toque no mapa ou use sua posição.'),
                style: AppTypography.body(
                    size: 10,
                    color: _lat != null ? AppColors.green : AppColors.text3),
              ),
              const SizedBox(height: 12),
              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_erro!, style: AppTypography.body(size: 10, color: AppColors.amber)),
                ),
              if (s.publishError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(s.publishError!,
                      style: AppTypography.body(size: 10, color: AppColors.amber)),
                ),
              AppButton(_sending ? 'PUBLICANDO…' : 'PUBLICAR NO CATÁLOGO',
                  onTap: _sending ? null : () => _publish(c), primary: !_sending),
            ],
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool number;
  final int lines;
  const _Field({required this.label, required this.controller, this.number = false, this.lines = 1});

  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLabel(label, color: AppColors.dim, size: 9),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderInput),
              borderRadius: r4,
            ),
            child: TextField(
              controller: controller,
              maxLines: lines,
              keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
              style: AppTypography.body(size: 11, color: AppColors.text),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      );
}
