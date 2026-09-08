import 'attr_model.dart';

/// O que persiste no Firestore em `users/{uid}` — o caderno de expedição
/// de verdade, não mais mockado em memória.
///
/// Campos que ainda são locais (mochila, janela de partida, bastão, chat)
/// não entram aqui nesta primeira etapa do backend — só autenticação e
/// perfil. O resto continua com os dados de demonstração do protótipo.
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
  });

  /// Perfil inicial de quem acabou de se cadastrar — nível 1, desnível
  /// zerado, atributos de base. O rank de partida vem da avaliação inicial
  /// (onboarding), não deste construtor.
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
      );
}
