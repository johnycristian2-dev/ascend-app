import 'cordada_catalog.dart';

/// Pessoa que o usuário pode adicionar como amigo.
///
/// ATENÇÃO: DEMONSTRAÇÃO. Não há contas reais por trás destes nomes — são
/// pessoas fictícias para mostrar o fluxo (buscar, pedir, aceitar, montar
/// cordada). Amigos entre contas reais (Firestore) é um próximo passo.
class Person {
  final String id;
  final String nome;
  final String rank; // letra E..S
  final String regiao;
  final bool online;
  const Person(this.id, this.nome, this.rank, this.regiao, {this.online = true});

  CordadaMember comoMembro() =>
      CordadaMember(nome.toUpperCase(), rank, online ? 'online' : 'fora de alcance', online: online);
}

const peopleDemo = <Person>[
  Person('kai', 'Kai', 'B', 'Curitiba · PR', online: false),
  Person('nina', 'Nina', 'A', 'Morretes · PR'),
  Person('teo', 'Téo', 'D', 'Joinville · SC'),
  Person('mai', 'Mai', 'C', 'Florianópolis · SC'),
  Person('bia', 'Bia', 'C', 'São Paulo · SP'),
  Person('rui', 'Rui', 'D', 'Campinas · SP'),
  Person('leo', 'Léo', 'E', 'Guaratinguetá · SP', online: false),
  Person('duda', 'Duda', 'A', 'Itatiaia · RJ'),
  Person('ian', 'Ian', 'B', 'Resende · RJ'),
  Person('lua', 'Lua', 'B', 'Cunha · SP', online: false),
  Person('oto', 'Oto', 'S', 'Passa Quatro · MG'),
];

Person? pessoaPorId(String id) {
  for (final p in peopleDemo) {
    if (p.id == id) return p;
  }
  return null;
}
