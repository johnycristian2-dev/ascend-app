/// Uma trilha do catálogo. `fonte` diz de onde veio: 'curadoria' (lista
/// embutida no app) ou 'comunidade' (publicada por um usuário, vive na
/// coleção `trails` do Firestore).
class CatalogTrail {
  final String id;
  final String nome;
  final int rankIdx; // 0=E .. 5=S — rank mínimo sugerido
  final double km;
  final int ganhoM;
  final String duracao;
  final String regiao;
  final String nota; // o que o próximo montanhista precisa saber
  final String autorNome;
  final String autorUid;
  final String fonte;
  final int criadoEmMs;

  /// Localização (cume ou início) — opcional: sem ela o mapa avisa em vez
  /// de chutar um lugar.
  final double? lat;
  final double? lon;

  /// true quando o ponto é só a região da trilha (não o cume nem o início):
  /// o mapa leva até lá e diz que é aproximado, em vez de fingir precisão.
  final bool aprox;

  const CatalogTrail({
    required this.id,
    required this.nome,
    required this.rankIdx,
    required this.km,
    required this.ganhoM,
    required this.duracao,
    this.regiao = '',
    this.nota = '',
    this.autorNome = '',
    this.autorUid = '',
    this.fonte = 'comunidade',
    this.criadoEmMs = 0,
    this.lat,
    this.lon,
    this.aprox = false,
  });

  bool get temLocal => lat != null && lon != null;

  bool get daComunidade => fonte == 'comunidade';

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'rankIdx': rankIdx,
        'km': km,
        'ganhoM': ganhoM,
        'duracao': duracao,
        'regiao': regiao,
        'nota': nota,
        'autorNome': autorNome,
        'autorUid': autorUid,
        'fonte': fonte,
        'criadoEmMs': criadoEmMs,
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
        if (aprox) 'aprox': true,
      };

  factory CatalogTrail.fromMap(String id, Map<String, dynamic> m) => CatalogTrail(
        id: id,
        nome: (m['nome'] as String?) ?? '',
        rankIdx: ((m['rankIdx'] as num?) ?? 0).toInt().clamp(0, 5),
        km: ((m['km'] as num?) ?? 0).toDouble(),
        ganhoM: ((m['ganhoM'] as num?) ?? 0).toInt(),
        duracao: (m['duracao'] as String?) ?? '',
        regiao: (m['regiao'] as String?) ?? '',
        nota: (m['nota'] as String?) ?? '',
        autorNome: (m['autorNome'] as String?) ?? '',
        autorUid: (m['autorUid'] as String?) ?? '',
        fonte: (m['fonte'] as String?) ?? 'comunidade',
        criadoEmMs: ((m['criadoEmMs'] as num?) ?? 0).toInt(),
        lat: (m['lat'] as num?)?.toDouble(),
        lon: (m['lon'] as num?)?.toDouble(),
        aprox: (m['aprox'] as bool?) ?? false,
      );
}
