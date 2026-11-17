/// Integrante de uma cordada.
///
/// ATENÇÃO: não existe conta nem convite real por trás destes nomes — as
/// cordadas e seus integrantes são DEMONSTRAÇÃO (fictícios), para mostrar o
/// fluxo de entrar, sair e ver quem está no grupo. Cordada real (convite,
/// contas, posição compartilhada) é um próximo passo.
class CordadaMember {
  final String nome;
  final String rank; // letra E..S
  final String status;
  final bool online;
  const CordadaMember(this.nome, this.rank, this.status, {this.online = true});
}

class Cordada {
  final String id;
  final String nome;
  final String trilha;
  final String descricao;
  final List<CordadaMember> membros;

  /// Ids dos amigos (só nas cordadas montadas pelo usuário).
  final List<String> membrosIds;
  const Cordada(this.id, this.nome, this.trilha, this.descricao, this.membros,
      {this.membrosIds = const []});
}

/// Cordadas de demonstração. O usuário entra como mais um integrante.
const cordadasDemo = <Cordada>[
  Cordada('sul', 'CORDADA SUL', 'Pico Paraná · travessia', 'Saídas de fim de semana pelo Sul', [
    CordadaMember('KAI', 'B', 'fora de alcance desde 08:26', online: false),
    CordadaMember('NINA', 'A', 'a caminho do ponto de encontro'),
    CordadaMember('TÉO', 'D', 'online'),
  ]),
  Cordada('madrugadores', 'MADRUGADORES', 'Pedra do Baú · 1 dia', 'Saem às 4 da manhã, voltam para o almoço', [
    CordadaMember('BIA', 'C', 'online'),
    CordadaMember('RUI', 'D', 'online'),
    CordadaMember('LÉO', 'E', 'visto há 2 h', online: false),
  ]),
  Cordada('mantiqueira', 'MANTIQUEIRA', 'Agulhas Negras · Marins', 'Altitude e frio: só com rank B ou mais', [
    CordadaMember('DUDA', 'A', 'online'),
    CordadaMember('IAN', 'B', 'online'),
    CordadaMember('LUA', 'B', 'fora de alcance', online: false),
    CordadaMember('OTO', 'S', 'online'),
  ]),
];

Cordada? cordadaPorId(String id) {
  for (final c in cordadasDemo) {
    if (c.id == id) return c;
  }
  return null;
}
