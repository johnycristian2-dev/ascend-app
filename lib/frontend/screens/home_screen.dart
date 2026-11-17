import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../app.dart';
import '../../backend/state/expedition_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/radio_composer.dart';
import '../widgets/widgets.dart';

/// Mapa da trilha: o painel de comando da expedição ativa.
///
/// O mapa é o protagonista: ocupa quase toda a tela. O resto (cabeçalho,
/// indicadores e botões) fica compacto, em faixas finas ao redor dele. Os
/// detalhes (dia 1, mochila, janela, recados) seguem a um toque de distância.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    if (s.empty) return const _EmptyHome();

    final cond = condData[s.trail]!;

    Widget mapa(double h) => RouteMap(
          height: h,
          labelTopLeft: 'MAPA · ${s.activeTrail.regiao.isNotEmpty ? s.activeTrail.regiao.toUpperCase() : s.activeTrail.nome}',
          center: s.activeTrail.temLocal ? ll.LatLng(s.activeTrail.lat!, s.activeTrail.lon!) : null,
          trackAsset: s.activeTrail.id == 'seed-ruy-braga' ? 'assets/routes/ruy_braga.gpx' : null,
          labelBottomRight: cond.label,
          labelBottomRightColor: AppColors.tagInks[0],
          recorded: [for (final p in s.shownTrack) ll.LatLng(p.lat, p.lon)],
          me: s.myPos == null ? null : ll.LatLng(s.myPos!.lat, s.myPos!.lon),
        );

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.activeTrail.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.num(size: 16, color: AppColors.text)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Flexible(
                    child: Text(
                        '${fmtDec(s.activeKm)} km · +${fmtMil(s.activeM)} m'
                        '${s.activeTrail.duracao.isEmpty ? '' : ' · ${s.activeTrail.duracao}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(size: 9.5, color: AppColors.text3)),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => s.go('discover'),
                    child: const AppLabel('TROCAR ›', color: AppColors.amber, size: 8.5, tracking: 0.2),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        AppTag('RANK ${s.rank}', AppColors.amber),
        const SizedBox(width: 8),
        _IconBtn(Icons.terrain, s.enterField),
        const SizedBox(width: 6),
        _IconBtn(Icons.radio_outlined, () => openRadioComposer(c)),
      ],
    );

    // Faixa de indicadores: pequena de propósito, o mapa é quem manda.
    final chips = Row(
      children: [
        Expanded(
          child: _Mini('JANELA', fmtClock(s.wxSec), AppColors.amber, () => s.go('window'),
              warn: true),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _Mini('CHEGADA', s.arrive,
              s.dark ? AppColors.amber : AppColors.textStrong, () => s.go('route')),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _Mini(
              'MOCHILA',
              '${fmtDec(s.kg)} kg',
              s.overweight ? AppColors.amber : AppColors.green,
              () => s.go('pack'),
              warn: s.overweight),
        ),
        const SizedBox(width: 6),
        Expanded(child: _Mini('BASTÃO', '${s.relayCount}', AppColors.textStrong, () => s.go('relay'))),
      ],
    );

    final gpsStatus = Text(
      s.locationError ??
          (s.tracking
              ? 'GPS ligado · ${fmtDec(s.shownTrackKm, 2)} km gravados'
              : s.shownTrack.length >= 2
                  ? 'Último traçado: ${fmtDec(s.shownTrackKm, 2)} km'
                  : 'GPS desligado'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.body(
          size: 9.5, color: s.locationError != null ? AppColors.amber : AppColors.text2),
    );

    final conflicts = s.core.conflicts.isEmpty
        ? null
        : Text(
            s.core.conflicts.length == 1
                ? 'A partida exige 1 item que ficou em casa'
                : 'A partida exige ${s.core.conflicts.length} itens que ficaram em casa',
            style: AppTypography.body(size: 9.5, color: AppColors.amber));

    final actions = Row(
      children: [
        Expanded(
          child: AppButton(s.tracking ? 'PARAR GPS' : 'INICIAR GPS',
              onTap: s.tracking ? s.stopTracking : s.startTracking),
        ),
        const SizedBox(width: 8),
        Expanded(child: AppButton('CONCLUIR', onTap: s.finish, primary: true)),
      ],
    );

    final bottom = <Widget>[
      const SizedBox(height: 6),
      gpsStatus,
      const SizedBox(height: 8),
      chips,
      if (conflicts != null) ...[const SizedBox(height: 6), conflicts],
      const SizedBox(height: 8),
      actions,
    ];

    return LayoutBuilder(builder: (context, box) {
      final tall = box.maxHeight >= 560;
      if (tall) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: 8),
              Expanded(child: mapa(double.infinity)),
              ...bottom,
            ],
          ),
        );
      }
      // Tela baixa (janela pequena/paisagem): mantém o mapa grande e deixa
      // o resto rolar, em vez de estourar o layout.
      return ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        children: [header, const SizedBox(height: 8), mapa(360), ...bottom],
      );
    });
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext c) => InkWell(
        onTap: onTap,
        borderRadius: r4,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: r4,
          ),
          child: Icon(icon, size: 16, color: AppColors.text2),
        ),
      );
}

class _Mini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final bool warn;
  const _Mini(this.label, this.value, this.color, this.onTap, {this.warn = false});

  @override
  Widget build(BuildContext c) => InkWell(
        onTap: onTap,
        borderRadius: r4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: warn ? AppColors.bgWarn : AppColors.surface,
            border: Border.all(color: warn ? AppColors.borderWarn : AppColors.border),
            borderRadius: r4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppLabel(label, color: AppColors.dim, size: 7.5, tracking: 0.16),
              const SizedBox(height: 3),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.num(size: 13, color: color)),
            ],
          ),
        ),
      );
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLabel('NENHUMA EXPEDIÇÃO', color: AppColors.dim, size: 9, tracking: 0.26),
          const SizedBox(height: 8),
          Text('O mapa começa vazio.', style: AppTypography.num(size: 26, color: AppColors.text)),
          const SizedBox(height: 10),
          Text(
            'Escolha uma trilha do seu rank ou entre na cordada de alguém. O registro começa na primeira saída.',
            style: AppTypography.body(size: 11),
          ),
          const SizedBox(height: 20),
          AppButton('VER TRILHAS DO MEU RANK',
              onTap: () => s.go('discover'), primary: true),
          const SizedBox(height: 8),
          AppButton('PLANEJAR EXPEDIÇÃO', onTap: () => s.go('plan')),
        ],
      ),
    );
  }
}
