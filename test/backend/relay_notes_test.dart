import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/backend/data/relay_notes.dart';

void main() {
  group('recado de bastão apaga de forma contínua', () {
    test('fica em opacidade plena até 30 dias sem confirmação', () {
      const n = RelayNote(
        who: 'X', rank: 'C', ago: 'há 1 mês', km: '1,0', at: 'KM 1,0',
        conf: 1, last: 'há 30 dias', stale: false, text: '',
        diasDesdeConfirmacao: 30,
      );
      expect(n.fadeOpacity(), 1.0);
    });

    test('decai continuamente entre 30 e 182 dias, nunca de uma vez', () {
      const n = RelayNote(
        who: 'X', rank: 'C', ago: 'há 2 meses', km: '1,0', at: 'KM 1,0',
        conf: 1, last: 'há 60 dias', stale: false, text: '',
        diasDesdeConfirmacao: 60,
      );
      const m = RelayNote(
        who: 'X', rank: 'C', ago: 'há 4 meses', km: '1,0', at: 'KM 1,0',
        conf: 1, last: 'há 120 dias', stale: false, text: '',
        diasDesdeConfirmacao: 120,
      );
      expect(n.fadeOpacity(), lessThan(1.0));
      expect(m.fadeOpacity(), lessThan(n.fadeOpacity()));
    });

    test('nunca cai abaixo do piso de .35, mesmo passado 6 meses', () {
      const n = RelayNote(
        who: 'X', rank: 'C', ago: 'há 1 ano', km: '1,0', at: 'KM 1,0',
        conf: 1, last: 'há 400 dias', stale: false, text: '',
        diasDesdeConfirmacao: 400,
      );
      expect(n.fadeOpacity(), 0.35);
    });

    test('confirmar agora (diasOverride: 0) devolve a opacidade plena', () {
      const n = RelayNote(
        who: 'X', rank: 'C', ago: 'há 5 meses', km: '1,0', at: 'KM 1,0',
        conf: 1, last: 'há 150 dias', stale: true, text: '',
        diasDesdeConfirmacao: 150,
      );
      expect(n.fadeOpacity(), lessThan(1.0));
      expect(n.fadeOpacity(diasOverride: 0), 1.0);
    });

    test('um recado antigo mas confirmado recentemente não está apagado', () {
      // O recado do cume: postado há 1 ano, mas confirmado há 6 dias.
      final cume = relayData[4];
      expect(cume.diasDesdeConfirmacao, 6);
      expect(cume.fadeOpacity(), 1.0);
    });
  });
}
