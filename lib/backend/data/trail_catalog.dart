import '../models/catalog_trail_model.dart';

/// Curadoria embutida: as trilhas que o app já mostrava desde o protótipo.
/// Os números são os do protótipo (referência), não medições — quem sobe
/// deve conferir antes. É também o que aparece se a coleção da comunidade
/// estiver indisponível (sem rede ou regras ainda não publicadas).
const trailCatalogSeed = <CatalogTrail>[
  CatalogTrail(
      id: 'seed-ruy-braga', nome: 'TRAVESSIA RUY BRAGA', rankIdx: 3, km: 28.4, ganhoM: 1640,
      duracao: '2 dias', nota: 'chaminé de 12 m no km 26', autorNome: 'Ascend', fonte: 'curadoria'),
  CatalogTrail(
      id: 'seed-pedra-do-bau', nome: 'PEDRA DO BAÚ', rankIdx: 1, km: 9.2, ganhoM: 780,
      duracao: '1 dia', nota: 'escadas de ferro expostas', autorNome: 'Ascend', fonte: 'curadoria'),
  CatalogTrail(
      id: 'seed-agulhas-negras', nome: 'AGULHAS NEGRAS · FACE SUL', rankIdx: 4, km: 14.6, ganhoM: 1180,
      duracao: '2 dias', nota: 'gelo vivo de junho a agosto', autorNome: 'Ascend', fonte: 'curadoria'),
  CatalogTrail(
      id: 'seed-prateleiras', nome: 'PRATELEIRAS', rankIdx: 2, km: 11.8, ganhoM: 640,
      duracao: '1 dia', nota: 'campo de blocos sem marcação', autorNome: 'Ascend', fonte: 'curadoria'),
  CatalogTrail(
      id: 'seed-pico-dos-marins', nome: 'PICO DOS MARINS', rankIdx: 2, km: 12.4, ganhoM: 1020,
      duracao: '1 dia', nota: 'vento constante na crista', autorNome: 'Ascend', fonte: 'curadoria'),
];
