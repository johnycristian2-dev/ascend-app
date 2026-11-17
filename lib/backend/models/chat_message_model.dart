/// Uma mensagem da cordada (`chat`). `me` diferencia o que você escreveu
/// do que a cordada escreveu — é só isso que decide o lado da bolha.
class Msg {
  final String who, time, text;
  final bool me;

  /// Mensagem de SOS: aparece destacada na conversa da cordada.
  final bool sos;
  const Msg(this.who, this.time, this.text, this.me, {this.sos = false});

  Map<String, dynamic> toMap() => {'who': who, 'time': time, 'text': text, 'me': me, if (sos) 'sos': true};

  factory Msg.fromMap(Map<String, dynamic> m) => Msg(
        (m['who'] as String?) ?? '',
        (m['time'] as String?) ?? '',
        (m['text'] as String?) ?? '',
        (m['me'] as bool?) ?? false,
        sos: (m['sos'] as bool?) ?? false,
      );
}
