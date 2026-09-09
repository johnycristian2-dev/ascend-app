import 'attr_model.dart';

/// O que persiste no Firestore em `users/{uid}` — o caderno de expedição
/// de verdade, não mais mockado em memória.
///
/// `packOut`, a partida escolhida e os votos/dívidas de bastão persistem
/// porque são decisões que não fazem sentido resetar toda vez que o app
/// abre. O resto (janela em contagem regressiva, plano de expedição,
/// convocação de cordada, chat, equipamento) continua local, com os
/// dados de demonstração do protótipo — é a próxima fatia de backend.
class UserProfile {
  final String uid;
  final String name;
  final String baseName;
  final String units;
  final int level;
  final int elev;
  final int elevGoal;
  final int rankIdx;
  final List<Attr> attrs;

  /// Itens deixados em casa, pelo NOME — ver ESPEC-Flutter.md §3.
  final List<String> packOut;

  /// Índice da partida escolhida na janela de tempo (ver `wx_slots`).
  final int wxPick;

  /// Voto em cada recado de bastão, por índice do recado (como string,
  /// chave de mapa no Firestore) -> 'y' (ainda vale) ou 'n' (não achei).
  final Map<String, String> relayVotes;

  /// Índices de recados abertos em campo e ainda sem voto — a dívida de
  /// confirmação que trava o arquivamento do registro (ver `fileRecord`).
  final List<int> relayUsed;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.baseName,
    required this.units,
    required this.level,
    required this.elev,
    required this.elevGoal,
    required this.rankIdx,
    required this.attrs,
    this.packOut = const [],
    this.wxPick = 0,
    this.relayVotes = const {},
    this.relayUsed = const [],
  });

  /// Perfil inicial de quem acabou de se cadastrar — nível 1, desnível
  /// zerado, atributos de base, nada decidido ainda na mochila/janela/
  /// bastão. O rank de partida vem da avaliação inicial (onboarding),
  /// não deste construtor.
  factory UserProfile.starter({
    required String uid,
    required String name,
    required int rankIdx,
  }) =>
      UserProfile(
        uid: uid,
        name: name,
        baseName: '',
        units: 'métrico',
        level: 1,
        elev: 0,
        elevGoal: 6000,
        rankIdx: rankIdx,
        attrs: const [
          Attr('RESISTÊNCIA', 20),
          Attr('FORÇA', 20),
          Attr('TÉCNICA', 20),
          Attr('ALTITUDE', 20),
        ],
      );

  UserProfile copyWith({
    String? name,
    String? baseName,
    String? units,
    int? level,
    int? elev,
    int? elevGoal,
    int? rankIdx,
    List<Attr>? attrs,
    List<String>? packOut,
    int? wxPick,
    Map<String, String>? relayVotes,
    List<int>? relayUsed,
  }) =>
      UserProfile(
        uid: uid,
        name: name ?? this.name,
        baseName: baseName ?? this.baseName,
        units: units ?? this.units,
        level: level ?? this.level,
        elev: elev ?? this.elev,
        elevGoal: elevGoal ?? this.elevGoal,
        rankIdx: rankIdx ?? this.rankIdx,
        attrs: attrs ?? this.attrs,
        packOut: packOut ?? this.packOut,
        wxPick: wxPick ?? this.wxPick,
        relayVotes: relayVotes ?? this.relayVotes,
        relayUsed: relayUsed ?? this.relayUsed,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'baseName': baseName,
        'units': units,
        'level': level,
        'elev': elev,
        'elevGoal': elevGoal,
        'rankIdx': rankIdx,
        'attrs': attrs.map((a) => a.toMap()).toList(),
        'packOut': packOut,
        'wxPick': wxPick,
        'relayVotes': relayVotes,
        'relayUsed': relayUsed,
      };

  factory UserProfile.fromMap(String uid, Map<String, dynamic> m) => UserProfile(
        uid: uid,
        name: (m['name'] as String?) ?? 'Montanhista',
        baseName: (m['baseName'] as String?) ?? '',
        units: (m['units'] as String?) ?? 'métrico',
        level: ((m['level'] as num?) ?? 1).toInt(),
        elev: ((m['elev'] as num?) ?? 0).toInt(),
        elevGoal: ((m['elevGoal'] as num?) ?? 6000).toInt(),
        rankIdx: ((m['rankIdx'] as num?) ?? 0).toInt(),
        attrs: (m['attrs'] as List?)
                ?.map((a) => Attr.fromMap(Map<String, dynamic>.from(a as Map)))
                .toList() ??
            const [
              Attr('RESISTÊNCIA', 20),
              Attr('FORÇA', 20),
              Attr('TÉCNICA', 20),
              Attr('ALTITUDE', 20),
            ],
        packOut: (m['packOut'] as List?)?.map((e) => e as String).toList() ?? const [],
        wxPick: ((m['wxPick'] as num?) ?? 0).toInt(),
        relayVotes: (m['relayVotes'] as Map?)?.map((k, v) => MapEntry(k as String, v as String)) ??
            const {},
        relayUsed: (m['relayUsed'] as List?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      );
}
