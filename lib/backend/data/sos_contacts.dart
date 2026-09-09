/// Destinatário do alerta de emergência — quem a tela de SOS mostra pra
/// enviar a posição. `dotInk`: mesmo índice de `AppColors.tagInks`
/// (0 azul, 1 verde, 2 âmbar, 3 cinza) — resolvido na UI, este arquivo
/// não importa Flutter.
class SosContact {
  final String name;
  final String role;
  final String via;
  final int dotInk;
  const SosContact(this.name, this.role, this.via, this.dotInk);
}

const sosContacts = <SosContact>[
  SosContact('CORDADA SUL', '3 integrantes em campo', 'RÁDIO + APP', 1),
  SosContact('BASE ITATIAIA', 'Guarda do parque · 24 h', 'SATÉLITE', 2),
  SosContact('MARINA DUARTE', 'Contato pessoal', 'SMS', 0),
];
