import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';

/// Bytes crus de uma gravação + o tipo de contêiner que o navegador
/// escolheu de verdade (Chrome grava Opus dentro de WebM). Sem isso,
/// tocar de volta com o MIME errado simplesmente fica mudo — nenhum
/// erro, nenhum som.
class RadioCapture {
  final List<int> bytes;
  final String mime;
  const RadioCapture(this.bytes, this.mime);
  String get base64 => base64Encode(bytes);
}

/// Fina camada sobre o `record` — a UI/estado nunca fala com
/// `AudioRecorder` direto, só com isto aqui (mesmo padrão de
/// `AuthService`/`ProfileRepository`).
///
/// Só a Web foi testada (é a única plataforma que dá pra rodar neste
/// ambiente). No Flutter Web, `AudioRecorder.stop()` devolve uma blob
/// URL, não um caminho de arquivo — [stop] busca os bytes de verdade
/// com uma requisição HTTP normal nessa URL (funciona porque uma blob
/// URL é só mais um recurso do mesmo documento) e lê o `Content-Type`
/// da resposta, que é o MIME real escolhido pelo navegador.
class RadioService {
  final AudioRecorder _recorder;
  RadioService([AudioRecorder? recorder]) : _recorder = recorder ?? AudioRecorder();

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> start() => _recorder.start(
        const RecordConfig(encoder: AudioEncoder.opus),
        path: 'ascend_radio_${DateTime.now().millisecondsSinceEpoch}.webm',
      );

  Future<RadioCapture?> stop() async {
    final url = await _recorder.stop();
    if (url == null) return null;
    final res = await http.get(Uri.parse(url));
    return RadioCapture(res.bodyBytes, res.headers['content-type'] ?? 'audio/webm');
  }

  Future<void> cancel() => _recorder.cancel();
  void dispose() => _recorder.dispose();
}
