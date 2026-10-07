/// Uma nota do diário de bordo — escrita em campo ("MARCAR" no modo
/// campo, `openLog`/`addNote` no protótipo), uma linha sobre o trecho
/// onde você está agora. Só existe dentro do próprio diário: ao
/// contrário de um recado de bastão, não é compartilhada com ninguém.
class LogEntry {
  final String seg;
  final String time;
  final String text;
  const LogEntry(this.seg, this.time, this.text);

  Map<String, dynamic> toMap() => {'seg': seg, 'time': time, 'text': text};

  factory LogEntry.fromMap(Map<String, dynamic> m) => LogEntry(
        (m['seg'] as String?) ?? '',
        (m['time'] as String?) ?? '',
        (m['text'] as String?) ?? '',
      );
}
