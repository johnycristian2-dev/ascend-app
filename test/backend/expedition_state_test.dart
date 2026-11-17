import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/backend/services/auth_service.dart';
import 'package:ascend/backend/services/profile_repository.dart';
import 'package:ascend/backend/data/trail_catalog.dart';
import 'package:ascend/backend/data/cordada_catalog.dart';
import 'package:ascend/backend/data/gear_catalog.dart';
import 'package:ascend/backend/models/catalog_trail_model.dart';
import 'package:ascend/backend/geo/gpx_parser.dart';
import 'package:ascend/backend/services/location_service.dart';
import 'package:ascend/backend/services/radio_service.dart';
import 'package:ascend/backend/services/trail_repository.dart';
import 'package:ascend/backend/state/expedition_calculator.dart';
import 'package:ascend/backend/state/expedition_state.dart';

// Dublês que não tocam em Firebase nem no microfone: o estado só os usa
// quando há uid logado, o que não é o caso nestes testes (uid == null, então
// _syncProfile() retorna cedo).
class _FakeAuth implements AuthService {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeProfiles implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeRadio implements RadioService {
  @override
  void dispose() {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeTrails implements TrailRepository {
  final List<CatalogTrail> store = [];
  bool falha = false;
  @override
  Future<List<CatalogTrail>> fetchAll() async {
    if (falha) throw Exception('sem rede');
    return List.of(store);
  }

  @override
  Future<void> publish(CatalogTrail t) async {
    if (falha) throw Exception('sem rede');
    store.insert(0, t);
  }
}

class _FakeLocation implements LocationService {
  String? problema;
  final ctrl = StreamController<LocationFix>();
  @override
  Future<String?> ensurePermission() async => problema;
  @override
  Stream<LocationFix> fixes() => ctrl.stream;
}

ExpeditionState _novoEstado([_FakeTrails? trails, _FakeLocation? loc]) => ExpeditionState(
    location: loc ?? _FakeLocation(),
    auth: _FakeAuth(),
    profiles: _FakeProfiles(),
    radioService: _FakeRadio(),
    trails: trails ?? _FakeTrails());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // O ExpeditionState cria um AudioPlayer, que fala com plugin nativo —
  // aqui os canais são respondidos vazios, só para o construtor não falhar.
  setUpAll(() {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final canal in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      messenger.setMockMethodCallHandler(MethodChannel(canal), (_) async => null);
    }
  });

  group('finish() aplica as fórmulas reais', () {
    test('XP, desnível e atributos refletem a rota resultante', () {
      final s = _novoEstado();
      final xp0 = s.xpTotal;
      final elev0 = s.elev;
      final res0 = s.attrs[0].val;
      final c = s.core;

      s.finish();

      final esperado = xpGanho(km: c.km, m: c.m, dificuldade: dificuldadeDe(s.trail));
      expect(s.lastXpGain, esperado);
      expect(s.xpTotal, xp0 + esperado);
      expect(s.lastElevGain, c.m);
      expect(s.elev, (elev0 + c.m).clamp(0, s.elevGoal));
      expect(s.attrs[0].val, (res0 + s.lastAttrGains.resistencia).clamp(0, 100));
      expect(s.screen, 'summary');
      s.dispose();
    });

    test('altitude é recorde: só sobe se a travessia superar o recorde', () {
      final s = _novoEstado();
      final recorde0 = s.recordAltimetriaM;
      final alt0 = s.attrs[3].val;
      final c = s.core;

      s.finish();

      if (c.m > recorde0) {
        expect(s.lastAltitudeRecord, isTrue);
        expect(s.recordAltimetriaM, c.m);
        expect(s.attrs[3].val, greaterThan(alt0));
      } else {
        expect(s.lastAltitudeRecord, isFalse);
        expect(s.recordAltimetriaM, recorde0);
        expect(s.attrs[3].val, alt0);
      }
      s.dispose();
    });

    test('o rank vem do XP acumulado, não de um incremento fixo', () {
      final s = _novoEstado();
      s.xpTotal = 6990; // logo abaixo do limiar de B (7.000)
      s.rankIdx = 2;
      s.finish();
      s.pending = true;
      s.fileRecord();
      expect(s.rankIdx, rankIdxForXp(s.xpTotal));
      expect(s.rankIdx, greaterThanOrEqualTo(3));
      s.dispose();
    });
  });

  group('catálogo da comunidade', () {
    test('sem publicações, mostra a curadoria; com publicações, comunidade vem antes', () async {
      final repo = _FakeTrails();
      final s = _novoEstado(repo);
      await s.loadCatalog();
      expect(s.catalog.length, trailCatalogSeed.length);
      expect(s.catalogOffline, isFalse);

      s.uid = 'u1';
      final ok = await s.publishTrail(
          nome: ' trilha teste ', rankIdx: 2, km: 5.5, ganhoM: 300,
          duracao: '1 dia', regiao: 'PR', nota: 'n');
      expect(ok, isTrue);
      expect(s.catalog.first.daComunidade, isTrue);
      expect(s.catalog.first.nome, 'TRILHA TESTE');
      expect(s.catalog.first.autorUid, 'u1');
      expect(s.catalog.length, trailCatalogSeed.length + 1);
      s.dispose();
    });

    test('falha de leitura cai na curadoria e avisa que está offline', () async {
      final repo = _FakeTrails()..falha = true;
      final s = _novoEstado(repo);
      await s.loadCatalog();
      expect(s.catalogOffline, isTrue);
      expect(s.catalog.length, trailCatalogSeed.length);
      s.dispose();
    });

    test('validação: exige login, nome e distância; falha de rede não publica', () async {
      final repo = _FakeTrails();
      final s = _novoEstado(repo);
      expect(await s.publishTrail(nome: 'x', rankIdx: 0, km: 1, ganhoM: 0, duracao: '', regiao: '', nota: ''), isFalse);
      s.uid = 'u1';
      expect(await s.publishTrail(nome: '  ', rankIdx: 0, km: 1, ganhoM: 0, duracao: '', regiao: '', nota: ''), isFalse);
      expect(await s.publishTrail(nome: 'x', rankIdx: 0, km: 0, ganhoM: 0, duracao: '', regiao: '', nota: ''), isFalse);
      repo.falha = true;
      expect(await s.publishTrail(nome: 'x', rankIdx: 0, km: 1, ganhoM: 0, duracao: '', regiao: '', nota: ''), isFalse);
      expect(s.publishError, isNotNull);
      expect(repo.store, isEmpty);
      s.dispose();
    });

    test('CatalogTrail faz ida e volta pelo mapa do Firestore', () {
      const t = CatalogTrail(id: 'a', nome: 'N', rankIdx: 9, km: 3.2, ganhoM: 100, duracao: '1 dia');
      final r = CatalogTrail.fromMap('a', t.toMap());
      expect((r.nome, r.km, r.ganhoM), ('N', 3.2, 100));
      expect(r.rankIdx, 5); // clamp: rank inválido não vaza
    });
  });

  group('GPS em tempo real', () {
    GeoPoint p(double m) => GeoPoint(-25.0 + m / 111320, -48.0);

    test('grava o traçado enquanto liga e guarda ao parar', () async {
      final loc = _FakeLocation();
      final s = _novoEstado(null, loc);
      await s.startTracking();
      expect(s.tracking, isTrue);
      loc.ctrl.add(LocationFix(p(0), 5));
      loc.ctrl.add(LocationFix(p(100), 5));
      loc.ctrl.add(LocationFix(p(200), 5));
      await Future<void>.delayed(Duration.zero);
      expect(s.myPos, p(200));
      expect(s.recorder.points.length, 3);
      await s.stopTracking();
      expect(s.tracking, isFalse);
      expect(s.savedTrack.length, 3);
      expect(s.savedTrackKm, closeTo(0.2, 0.005));
      s.dispose();
    });

    test('permissão negada não liga o GPS e mostra o motivo', () async {
      final loc = _FakeLocation()..problema = 'Permissão de localização negada.';
      final s = _novoEstado(null, loc);
      await s.startTracking();
      expect(s.tracking, isFalse);
      expect(s.locationError, 'Permissão de localização negada.');
      s.dispose();
    });
  });

  group('trilha em curso', () {
    test('escolher uma trilha do catálogo muda a expedição, o plano e o XP', () {
      final s = _novoEstado();
      final baoBau = trailCatalogSeed.firstWhere((t) => t.id == 'seed-pedra-do-bau');
      s.selectTrail(baoBau);
      expect(s.activeTrail.id, 'seed-pedra-do-bau');
      expect(s.screen, 'plan');
      // Sem variantes de mochila a rota-base não muda; com elas, só o delta.
      final deltaKm = s.core.km - 28.4;
      expect(s.activeKm, closeTo(9.2 + deltaKm, 1e-9));
      final xp0 = s.xpTotal;
      s.finish();
      expect(s.lastElevGain, s.activeM);
      expect(s.xpTotal - xp0, s.lastXpGain);
      s.dispose();
    });

    test('toda trilha curada leva a um ponto do mapa; só Prateleiras é aproximada', () {
      expect(trailCatalogSeed.every((t) => t.temLocal), isTrue);
      final aprox = trailCatalogSeed.where((t) => t.aprox).map((t) => t.id).toSet();
      expect(aprox, {'seed-prateleiras'});
    });

    test('aprox faz ida e volta no mapa do Firestore', () {
      const t = CatalogTrail(
          id: 'a', nome: 'N', rankIdx: 0, km: 1, ganhoM: 1, duracao: '', lat: 1, lon: 2, aprox: true);
      expect(CatalogTrail.fromMap('a', t.toMap()).aprox, isTrue);
      expect(CatalogTrail.fromMap('b', {'nome': 'x'}).aprox, isFalse);
    });

    test('lat/lon fazem ida e volta no mapa do Firestore', () {
      const t = CatalogTrail(
          id: 'a', nome: 'N', rankIdx: 0, km: 1, ganhoM: 1, duracao: '', lat: -25.1, lon: -48.2);
      final r = CatalogTrail.fromMap('a', t.toMap());
      expect((r.lat, r.lon, r.temLocal), (-25.1, -48.2, true));
    });
  });

  group('amigos, SOS, equipamento e trilhas (demonstração)', () {
    test('aceitar pedido vira amigo; recusar some; pedir é aceito sozinho', () async {
      final s = ExpeditionState(
          location: _FakeLocation(),
          auth: _FakeAuth(),
          profiles: _FakeProfiles(),
          radioService: _FakeRadio(),
          trails: _FakeTrails(),
          friendAcceptDelay: const Duration(milliseconds: 10));
      s.aceitarPedido('mai');
      expect(s.ehAmigo('mai'), isTrue);
      s.recusarPedido('bia');
      expect(s.friendsIn, isEmpty);
      s.pedirAmizade('leo');
      expect(s.friendsOut, ['leo']);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(s.ehAmigo('leo'), isTrue);
      expect(s.friendsOut, isEmpty);
      s.pedirAmizade('ian');
      s.cancelarPedido('ian');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(s.ehAmigo('ian'), isFalse);
      s.removerAmigo('kai');
      expect(s.ehAmigo('kai'), isFalse);
      s.dispose();
    });

    test('criar cordada só com amigos e entrar nela', () {
      final s = _novoEstado();
      s.criarCordada('Sexta no Paraná', ['kai', 'nina', 'oto']); // oto não é amigo
      expect(s.cordada?.nome, 'SEXTA NO PARANÁ');
      expect(s.cordada!.membrosIds, ['kai', 'nina']);
      expect(s.todasCordadas.length, cordadasDemo.length + 1);
      s.dispose();
    });

    test('SOS posta mensagem na cordada; cancelar avisa que está seguro', () {
      final s = _novoEstado();
      final antes = s.msgs.length;
      s.openSos();
      s.confirmSos();
      expect(s.msgs.length, antes + 1);
      expect(s.msgs.last.sos, isTrue);
      expect(s.msgs.last.me, isTrue);
      expect(s.sosMessage, contains('SOS ACIONADO'));
      s.cancelSos();
      expect(s.msgs.last.text, contains('SOS CANCELADO'));
      expect(s.sosOpen, isFalse);
      // round-trip do flag
      expect(Msg.fromMap(s.msgs.last.toMap()).sos, isTrue);
      s.dispose();
    });

    test('todas as trilhas ficam liberadas independente do rank', () {
      final s = _novoEstado();
      s.rankIdx = 0;
      for (final t in s.catalog) {
        expect(s.trilhaBloqueada(t), isFalse);
      }
      s.dispose();
    });

    test('cadastrar equipamento valida, lista, registra saída e remove', () {
      final s = _novoEstado();
      expect(s.cadastrarEquip(nome: '', categoria: 'BASE', pesoKg: '1'), isNotNull);
      expect(s.cadastrarEquip(nome: 'X', categoria: 'BASE', pesoKg: 'abc'), isNotNull);
      final base = s.todosEquip.length;
      expect(
          s.cadastrarEquip(nome: 'Jaqueta', categoria: 'ABRIGO', pesoKg: '0,45', limite: '30'), isNull);
      expect(s.todosEquip.length, base + 1);
      final g = s.customGear.single;
      expect(g.kg, '0,45');
      expect(s.gearUsage(g.id).uses, 0);
      s.logGearOuting(g.id);
      expect(s.gearUsage(g.id).uses, 1);
      // persistência: toMap/fromMap
      final volta = GearItem.fromMap(g.toMap())!;
      expect(volta.nome, 'Jaqueta');
      expect(volta.lim, 30);
      s.removerEquip(g.id);
      expect(s.todosEquip.length, base);
      s.dispose();
    });
  });

  group('cordada (demonstração)', () {
    test('começa na Cordada Sul, sai e entra em outra', () {
      final s = _novoEstado();
      expect(s.cordada?.id, 'sul');
      s.sairCordada();
      expect(s.cordada, isNull);
      expect(s.cordadaId, '');
      s.entrarCordada('madrugadores');
      expect(s.cordada?.nome, 'MADRUGADORES');
      expect(s.screen, 'chat');
      s.dispose();
    });

    test('id desconhecido não entra em cordada nenhuma', () {
      final s = _novoEstado();
      s.entrarCordada('nao-existe');
      expect(s.cordadaId, 'sul');
      s.dispose();
    });
  });

  group('traçado GPX importado', () {
    const gpx = '<gpx><trk><trkseg>'
        '<trkpt lat="-25.25" lon="-48.81"></trkpt>'
        '<trkpt lat="-25.26" lon="-48.82"></trkpt>'
        '<trkpt lat="-25.27" lon="-48.83"></trkpt>'
        '</trkseg></trk></gpx>';

    test('só vale para a trilha para a qual foi importado', () {
      final s = _novoEstado();
      expect(s.importGpx(gpx), isNull);
      expect(s.activeGpx.length, 3);
      expect(s.activeGpxKm, greaterThan(0));
      s.activeTrail = trailCatalogSeed[1];
      expect(s.activeGpx, isEmpty);
      s.dispose();
    });

    test('arquivo sem traçado é recusado e não inventa pontos', () {
      final s = _novoEstado();
      expect(s.importGpx('<gpx></gpx>'), isNotNull);
      expect(s.activeGpx, isEmpty);
      s.dispose();
    });

    test('traçado grande é reduzido a 800 pontos mantendo início e fim', () {
      final s = _novoEstado();
      final big = StringBuffer('<gpx><trk><trkseg>');
      for (var i = 0; i < 3000; i++) {
        big.write('<trkpt lat="${-25 - i * 0.0001}" lon="-48.8"></trkpt>');
      }
      big.write('</trkseg></trk></gpx>');
      expect(s.importGpx(big.toString()), isNull);
      expect(s.activeGpx.length, 800);
      expect(s.activeGpx.first.lat, -25.0);
      expect(s.activeGpx.last.lat, closeTo(-25 - 2999 * 0.0001, 1e-9));
      s.removerGpx();
      expect(s.activeGpx, isEmpty);
      s.dispose();
    });
  });
}
