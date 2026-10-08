/// Um recado de rádio — "RÁDIO" no mapa ou no modo campo, do protótipo
/// (`openRadio`/`radios`). Ao contrário dos demais dados de demonstração
/// do app, a gravação é de verdade: [audioBase64] é áudio capturado pelo
/// microfone, não um enfeite.
///
/// [mime] vem do `Content-Type` real do blob gravado (ver
/// `ExpeditionState._stopRadioRecording`) — guardado em vez de fixo
/// porque o navegador escolhe o contêiner (`audio/webm`, `audio/ogg`...)
/// e tocar de volta com o tipo errado simplesmente fica mudo.
class RadioMessage {
  /// Identidade local (não vem do protótipo): a lista cresce por
  /// `insert(0, ...)`, então um índice não serve pra saber qual card
  /// está tocando — ver `ExpeditionState.playRadio`.
  final String id;
  final String who;
  final String at;
  final String time;
  final int durationSec;
  final String audioBase64;
  final String mime;

  /// Reflete `syncQueue` do protótipo: `true` enquanto a escrita no
  /// Firestore não confirma, sempre `false` depois de recarregado do
  /// caderno (se chegou até aqui, já está sincronizado).
  final bool pending;

  const RadioMessage({
    required this.id,
    required this.who,
    required this.at,
    required this.time,
    required this.durationSec,
    required this.audioBase64,
    required this.mime,
    this.pending = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'who': who,
        'at': at,
        'time': time,
        'durationSec': durationSec,
        'audioBase64': audioBase64,
        'mime': mime,
      };

  factory RadioMessage.fromMap(Map<String, dynamic> m) => RadioMessage(
        id: (m['id'] as String?) ?? '',
        who: (m['who'] as String?) ?? '',
        at: (m['at'] as String?) ?? '',
        time: (m['time'] as String?) ?? '',
        durationSec: ((m['durationSec'] as num?) ?? 0).toInt(),
        audioBase64: (m['audioBase64'] as String?) ?? '',
        mime: (m['mime'] as String?) ?? 'audio/webm',
      );
}
