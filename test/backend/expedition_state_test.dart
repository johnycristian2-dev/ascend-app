import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/backend/services/auth_service.dart';
import 'package:ascend/backend/services/profile_repository.dart';
import 'package:ascend/backend/services/radio_service.dart';
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

ExpeditionState _novoEstado() =>
    ExpeditionState(auth: _FakeAuth(), profiles: _FakeProfiles(), radioService: _FakeRadio());

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
}
