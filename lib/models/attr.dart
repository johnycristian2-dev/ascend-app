/// Um atributo físico (Resistência, Força, Técnica, Altitude máxima).
/// Vive no próprio arquivo porque é usado tanto pelo estado local quanto
/// pelo perfil persistido no Firestore.
class Attr {
  final String nome;
  final int val;
  const Attr(this.nome, this.val);

  Attr bump(int d) => Attr(nome, (val + d).clamp(0, 100));

  Map<String, dynamic> toMap() => {'nome': nome, 'val': val};

  factory Attr.fromMap(Map<String, dynamic> m) =>
      Attr(m['nome'] as String, (m['val'] as num).toInt());
}
