/// Uma mensagem da cordada (`chat`). `me` diferencia o que você escreveu
/// do que a cordada escreveu — é só isso que decide o lado da bolha.
class Msg {
  final String who, time, text;
  final bool me;
  const Msg(this.who, this.time, this.text, this.me);

  Map<String, dynamic> toMap() => {'who': who, 'time': time, 'text': text, 'me': me};

  factory Msg.fromMap(Map<String, dynamic> m) => Msg(
        (m['who'] as String?) ?? '',
        (m['time'] as String?) ?? '',
        (m['text'] as String?) ?? '',
        (m['me'] as bool?) ?? false,
      );
}
