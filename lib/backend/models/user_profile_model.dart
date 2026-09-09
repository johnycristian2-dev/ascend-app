import '../data/gear_catalog.dart';
import 'attr_model.dart';
import 'chat_message_model.dart';
import 'gear_usage_model.dart';

/// Conversa inicial de toda cordada recém-formada — a mesma que o
/// protótipo sempre mostrou. Flavor, não uma decisão do usuário: por
/// isso, ao contrário de [UserProfile.starter]'s outros campos, não
/// começa vazia.
const seedMsgs = <Msg>[
  Msg('KAI', '08:12', 'Saindo do abrigo agora. Vento forte na crista norte.', false),
  Msg('VOCÊ', '08:14', 'Copiado. Levo a corda extra de 60 m.', true),
  Msg('NINA', '08:20', 'Chego no ponto 2 em 40 min. Marquem no mapa.', false),
];

/// O que persiste no Firestore em `users/{uid}` — o caderno de expedição
/// de verdade, não mais mockado em memória.
///
/// Só a janela em contagem regressiva continua puramente local — o resto
/// do circuito de decisão, da cordada e do equipamento já persiste.
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

  /// Trilha e dia escolhidos na tela "Nova expedição".
  final int planTrail;
  final int planDate;

  /// Quem foi convocado pra cordada (nome-chave -> convidado?) e quem
  /// leva cada item do equipamento coletivo (nome-chave -> marcado?).
  final Map<String, bool> invited;
  final Map<String, bool> checked;

  /// Histórico da conversa da cordada.
  final List<Msg> msgs;

  /// Uso registrado de cada peça de equipamento, por id do catálogo
  /// (`GearItem.id`, em gear_catalog.dart). Ausente = conta anterior a
  /// este campo — ver `ExpeditionState.gearUsage`.
  final Map<String, GearUsage> gear;

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
    this.planTrail = 0,
    this.planDate = 8,
    this.invited = const {},
    this.checked = const {},
    this.msgs = seedMsgs,
    this.gear = const {},
  });

  /// Perfil inicial de quem acabou de se cadastrar — nível 1, desnível
  /// zerado, atributos de base, nada decidido ainda na mochila, janela,
  /// bastão, plano, cordada (só a conversa inicial, que é cenário, não
  /// decisão) ou equipamento (peças zeradas — novas em folha, ninguém
  /// registrou uma saída ainda). O rank de partida vem da avaliação
  /// inicial (onboarding), não deste construtor.
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
        gear: {for (final g in gearData) g.id: const GearUsage()},
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
    int? planTrail,
    int? planDate,
    Map<String, bool>? invited,
    Map<String, bool>? checked,
    List<Msg>? msgs,
    Map<String, GearUsage>? gear,
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
        planTrail: planTrail ?? this.planTrail,
        planDate: planDate ?? this.planDate,
        invited: invited ?? this.invited,
        checked: checked ?? this.checked,
        msgs: msgs ?? this.msgs,
        gear: gear ?? this.gear,
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
        'planTrail': planTrail,
        'planDate': planDate,
        'invited': invited,
        'checked': checked,
        'msgs': msgs.map((m) => m.toMap()).toList(),
        'gear': gear.map((k, v) => MapEntry(k, v.toMap())),
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
        planTrail: ((m['planTrail'] as num?) ?? 0).toInt(),
        planDate: ((m['planDate'] as num?) ?? 8).toInt(),
        invited: (m['invited'] as Map?)?.map((k, v) => MapEntry(k as String, v as bool)) ?? const {},
        checked: (m['checked'] as Map?)?.map((k, v) => MapEntry(k as String, v as bool)) ?? const {},
        msgs: (m['msgs'] as List?)
                ?.map((e) => Msg.fromMap(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            seedMsgs,
        gear: (m['gear'] as Map?)?.map(
              (k, v) => MapEntry(k as String, GearUsage.fromMap(Map<String, dynamic>.from(v as Map))),
            ) ??
            const {},
      );
}
