import 'package:flutter/foundation.dart';
import '../data/gear_catalog.dart';
import '../data/relay_notes.dart';
import '../data/weather_forecast.dart';
import '../models/attr_model.dart';
import '../models/chat_message_model.dart';
import '../models/gear_usage_model.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';
import 'expedition_calculator.dart';

export '../models/attr_model.dart' show Attr;
export '../models/chat_message_model.dart' show Msg;
export '../models/gear_usage_model.dart' show GearUsage;

const ranks = ['E', 'D', 'C', 'B', 'A', 'S'];

/// Estado global. As telas de decisão escrevem aqui; todo o resto é derivado.
class ExpeditionState extends ChangeNotifier {
  ExpeditionState({AuthService? auth, ProfileRepository? profiles})
      : auth = auth ?? AuthService(),
        profiles = profiles ?? ProfileRepository();

  /// Serviços de backend — a UI só fala com eles através dos métodos
  /// abaixo (signIn/signUp/signOut/completeOnboarding), nunca direto.
  final AuthService auth;
  final ProfileRepository profiles;

  /// uid do Firebase Auth da sessão atual. Nulo até logar.
  String? uid;
  bool authLoading = false;
  String? authError;

  String screen = 'splash';
  bool back = false; // direção da última navegação
  bool empty = false; // primeiro acesso, sem expedição

  int bootPct = 0;
  int level = 27;
  int elev = 4360;
  int elevGoal = 6000;
  int rankIdx = 3;
  String prevRank = 'C';
  bool pending = false;

  String name = 'Jota';
  String baseName = 'São Bento do Sapucaí';
  String units = 'métrico';

  // ------------------------------------------------------- identidade pública
  String photoUrl = '';
  String coverUrl = '';
  String bio = '';
  final Map<String, String> socialLinks = {};
  String practicingSince = '';
  String dreamTrail = '';
  String favoriteGear = '';

  int wxSec = 133964;
  int wxPick = 1;

  /// Itens DEIXADOS EM CASA, referenciados pelo nome.
  final Set<String> packOut = {'CRAMPONS', 'CÂMERA'};

  int? relaySel;
  String relayDraft = '';
  bool relaySent = false;
  final Map<int, String?> relayVote = {};

  int planTrail = 1;
  int planDate = 12;
  final Map<String, bool> invited = {
    'kai': true, 'nina': true, 'teo': false, 'mai': false
  };
  final Map<String, bool> checked = {
    'corda': true, 'barraca': true, 'kit': true,
    'radio': false, 'fogo': true, 'mapa': false
  };

  int? stampIdx;
  String? gearSel;
  bool cheered = false;
  String draft = '';

  /// Uso registrado por peça de equipamento (chave = GearItem.id). Vazio
  /// até a primeira sincronização — ver [gearUsage].
  final Map<String, GearUsage> gear = {};

  /// Ids de `achievementCatalog` já desbloqueados. Só cresce — ver [_unlock].
  final Set<String> unlockedAchievements = {};

  /// Modo campo: tela cheia de instrumento, acessível a partir do mapa.
  bool fieldMode = false;

  /// SOS: sobreposição de emergência, acessível a partir do modo campo —
  /// como `fieldMode`, não é uma tela do fluxo normal (não entra no mapa
  /// `depth`). Fica por cima até de `fieldMode` na pilha (ver app.dart).
  bool sosOpen = false;
  bool sosSent = false;

  /// Índices de recados de bastão que você abriu durante a expedição —
  /// a dívida de confirmação cobra a volta só de quem foi de fato usado.
  final Set<int> relayUsed = {};

  TrailState trail = TrailState.lama;

  List<Attr> attrs = const [
    Attr('RESISTÊNCIA', 78),
    Attr('FORÇA', 64),
    Attr('TÉCNICA', 71),
    Attr('ALTITUDE', 62),
  ];
  static const deltas = [4, 3, 5, 2];

  List<Msg> msgs = List.of(seedMsgs);

  // ------------------------------------------------------------- derivados

  String get rank => ranks[rankIdx];
  SlotMeta get slot => slotMeta[wxPick];
  WxSlot get wx => wxSlots[wxPick];

  LinkCore get core => linkCore(packOut: packOut, slotNeeds: slot.needs);
  int get gramas => packWeight(packOut);
  double get kg => gramas / 1000;
  bool get overweight => kg > 12;

  int get walk => walkMin(packOut: packOut, slotNeeds: slot.needs);
  int get day1 => day1Min(packOut: packOut, slotNeeds: slot.needs, trail: trail);
  String get arrive => addTime(slot.dep, day1);
  bool get dark => isDark(arrive, slot.lightPct);

  /// Minutos entre a chegada e o escuro. Negativo = chega depois.
  int get lightMargin {
    final p = arrive.split(':').map(int.parse).toList();
    return darkMin - (p[0] * 60 + p[1]);
  }

  int get varMin => core.min - baseMin;
  int get loadMin => walk - core.min;
  int get relayCount => relayData.length + (relaySent ? 1 : 0);

  /// Recados que você abriu em campo e ainda não confirmou nem negou.
  /// O app cobra essa confirmação antes de deixar arquivar o registro.
  List<int> get relayDebts =>
      relayUsed.where((i) => relayVote[i] == null).toList()..sort();

  /// Índice de confiança da rota — ver ESPEC-Flutter.md / calculator.
  RouteTrust get routeTrust => computeRouteTrust(relayVote);

  /// Uso de uma peça pelo id do catálogo. Se ainda não foi sincronizado
  /// (conta anterior a este campo, ou perfil que nunca registrou essa
  /// peça), cai nos números de demonstração do próprio catálogo — em vez
  /// de mostrar equipamento "novo em folha" pra quem já via outro valor.
  GearUsage gearUsage(String id) {
    final logged = gear[id];
    if (logged != null) return logged;
    final cat = gearData.firstWhere((g) => g.id == id);
    return GearUsage(uses: cat.uses, wear: cat.wear, od: cat.od);
  }

  // -------------------------------------------------------------- comandos

  static const depth = {
    'splash': 0, 'auth': 0, 'onboard': 1, 'home': 1, 'chat': 1, 'profile': 1,
    'inv': 2, 'ach': 2, 'history': 2, 'settings': 2, 'discover': 2, 'route': 2,
    'plan': 2, 'watch': 2, 'relay': 2, 'party': 3, 'summary': 3, 'window': 3,
    'rankup': 4, 'pack': 4,
  };

  /// Aba raiz destacada para telas mais profundas.
  String get activeTab {
    const toHome = ['route', 'discover', 'party', 'plan', 'watch', 'window', 'pack', 'relay'];
    const toProfile = ['rankup', 'summary', 'settings', 'history', 'inv', 'ach'];
    if (toHome.contains(screen)) return 'home';
    if (toProfile.contains(screen)) return 'profile';
    return screen;
  }

  void go(String s) {
    back = (depth[s] ?? 1) < (depth[screen] ?? 1);
    if (s == 'rankup') prevRank = ranks[(rankIdx - 1).clamp(0, 5)];
    screen = s;
    empty = false;
    notifyListeners();
  }

  void goEmptyHome() {
    back = true;
    screen = 'home';
    empty = true;
    notifyListeners();
  }

  void tickBoot() {
    if (bootPct >= 100) return;
    bootPct = (bootPct + 4).clamp(0, 100);
    notifyListeners();
  }

  /// Chamado uma vez, quando a barra de boot termina. Se já existe uma
  /// sessão do Firebase Auth, tenta abrir direto no caderno; senão, manda
  /// para o acesso. Não derruba o app se a rede falhar — só volta pro login.
  Future<void> finishBoot() async {
    final user = auth.currentUser;
    if (user == null) {
      screen = 'auth';
      notifyListeners();
      return;
    }
    uid = user.uid;
    try {
      final profile = await profiles.fetch(user.uid);
      if (profile != null) {
        _applyProfile(profile);
        screen = 'home';
      } else {
        // Conta existe mas a avaliação inicial nunca terminou de salvar.
        screen = 'onboard';
      }
    } catch (_) {
      screen = 'auth';
      authError = 'Não deu para recuperar sua sessão. Entre de novo.';
    }
    notifyListeners();
  }

  void _applyProfile(UserProfile p) {
    name = p.name;
    baseName = p.baseName;
    units = p.units;
    level = p.level;
    elev = p.elev;
    elevGoal = p.elevGoal;
    rankIdx = p.rankIdx;
    attrs = p.attrs;
    packOut
      ..clear()
      ..addAll(p.packOut);
    wxPick = p.wxPick;
    relayVote
      ..clear()
      ..addEntries(p.relayVotes.entries.map((e) => MapEntry(int.parse(e.key), e.value)));
    relayUsed
      ..clear()
      ..addAll(p.relayUsed);
    planTrail = p.planTrail;
    planDate = p.planDate;
    invited
      ..clear()
      ..addAll(p.invited);
    checked
      ..clear()
      ..addAll(p.checked);
    msgs = p.msgs;
    gear
      ..clear()
      ..addAll(p.gear);
    unlockedAchievements
      ..clear()
      ..addAll(p.unlockedAchievements);
    photoUrl = p.photoUrl;
    coverUrl = p.coverUrl;
    bio = p.bio;
    socialLinks
      ..clear()
      ..addAll(p.socialLinks);
    practicingSince = p.practicingSince;
    dreamTrail = p.dreamTrail;
    favoriteGear = p.favoriteGear;
  }

  /// Grava o essencial do caderno no Firestore. Silencioso de propósito —
  /// o Firestore já enfileira a escrita e sincroniza quando a rede voltar;
  /// não vale travar a navegação por causa disso.
  void _syncProfile() {
    final id = uid;
    if (id == null) return;
    profiles.update(id, {
      'name': name,
      'baseName': baseName,
      'units': units,
      'level': level,
      'elev': elev,
      'elevGoal': elevGoal,
      'rankIdx': rankIdx,
      'attrs': attrs.map((a) => a.toMap()).toList(),
      'packOut': packOut.toList(),
      'wxPick': wxPick,
      'relayVotes': {
        for (final e in relayVote.entries)
          if (e.value != null) '${e.key}': e.value!,
      },
      'relayUsed': relayUsed.toList(),
      'planTrail': planTrail,
      'planDate': planDate,
      'invited': invited,
      'checked': checked,
      'msgs': msgs.map((m) => m.toMap()).toList(),
      'gear': gear.map((k, v) => MapEntry(k, v.toMap())),
      'unlockedAchievements': unlockedAchievements.toList(),
      'photoUrl': photoUrl,
      'coverUrl': coverUrl,
      'bio': bio,
      'socialLinks': socialLinks,
      'practicingSince': practicingSince,
      'dreamTrail': dreamTrail,
      'favoriteGear': favoriteGear,
    }).catchError((_) {});
  }

  /// Desbloqueia uma conquista de `achievementCatalog` (por id) se ainda
  /// não estava. Não sincroniza sozinho — chame antes do `_syncProfile()`
  /// que o método que disparou a conquista já ia fazer de qualquer jeito,
  /// pra virar uma escrita só.
  void _unlock(String id) => unlockedAchievements.add(id);

  Future<String?> signIn({required String email, required String password}) async {
    authLoading = true;
    authError = null;
    notifyListeners();
    try {
      final user = await auth.signIn(email: email, password: password);
      uid = user.uid;
      final profile = await profiles.fetch(user.uid);
      if (profile != null) {
        _applyProfile(profile);
        go('home');
      } else {
        name = email.split('@').first;
        go('onboard');
      }
      return null;
    } catch (e) {
      return AuthService.friendlyMessage(e);
    } finally {
      authLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String fieldName,
  }) async {
    authLoading = true;
    authError = null;
    notifyListeners();
    try {
      final user = await auth.signUp(email: email, password: password);
      uid = user.uid;
      name = fieldName.trim().isEmpty ? email.split('@').first : fieldName.trim();
      go('onboard');
      return null;
    } catch (e) {
      return AuthService.friendlyMessage(e);
    } finally {
      authLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    uid = null;
    name = 'Jota';
    baseName = '';
    screen = 'auth';
    empty = false;
    notifyListeners();
  }

  /// Fecha a avaliação inicial: fixa o rank de partida, cria o documento
  /// de perfil no Firestore (primeira vez que este uid é gravado) e segue
  /// para [goTo].
  Future<void> completeOnboarding({required int rankIdx, required String goTo}) async {
    this.rankIdx = rankIdx;
    final id = uid;
    if (id != null) {
      try {
        final starter = UserProfile.starter(uid: id, name: name, rankIdx: rankIdx)
            .copyWith(baseName: baseName);
        await profiles.create(starter);
        // O caderno recém-criado começa com mochila/janela/bastão zerados
        // (ver UserProfile.starter) — aplica localmente pra não ficar com
        // os defaults de demonstração até a próxima gravação, que os
        // reescreveria no Firestore por cima do que acabou de ser criado.
        _applyProfile(starter);
      } catch (_) {
        // Sem rede agora — segue mesmo assim; o caderno tenta de novo
        // na próxima gravação (settings, fim de trilha, etc.).
      }
    }
    go(goTo);
  }

  void tickClock() {
    if (wxSec > 0) {
      wxSec--;
      notifyListeners();
    }
  }

  void pickWx(int i) {
    wxPick = i;
    _syncProfile();
    notifyListeners();
  }
  void setTrail(TrailState t) { trail = t; notifyListeners(); }

  /// Modo campo é uma sobreposição, não uma tela do fluxo — como no protótipo.
  void enterField() { fieldMode = true; notifyListeners(); }
  void exitField() { fieldMode = false; notifyListeners(); }

  void openSos() { sosOpen = true; sosSent = false; notifyListeners(); }
  void closeSos() { sosOpen = false; sosSent = false; notifyListeners(); }

  /// Chamado quando o gesto de "manter pressionado" completa 3 s. Não
  /// dispara nada de verdade — ver aviso na própria tela de SOS.
  void confirmSos() { sosSent = true; notifyListeners(); }

  void toggleCarry(String nome) {
    packOut.contains(nome) ? packOut.remove(nome) : packOut.add(nome);
    if (overweight) _unlock('peso_no_limite');
    if (kg < 10) _unlock('mochila_leve');
    _syncProfile();
    notifyListeners();
  }

  void voteRelay(int i, String v) {
    relayVote[i] = relayVote[i] == v ? null : v;
    if (relayVote[i] == 'y') {
      _unlock('primeira_confirmacao');
      if (relayData[i].diasDesdeConfirmacao > 182) _unlock('confirmou_recado_velho');
    }
    _syncProfile();
    notifyListeners();
  }

  void pickPin(int? i) {
    relaySel = relaySel == i ? null : i;
    // Abrir um recado em campo é usá-lo — a confirmação vira uma dívida.
    // Só sincroniza quando a dívida muda de verdade, não a cada seleção.
    if (relaySel != null && relayUsed.add(relaySel!)) _syncProfile();
    notifyListeners();
  }
  void setRelayDraft(String v) {
    relayDraft = v.length > 180 ? v.substring(0, 180) : v;
    notifyListeners();
  }
  void sendRelay() {
    if (relayDraft.trim().isEmpty) return;
    relaySent = true;
    relayDraft = '';
    _unlock('primeiro_recado');
    _syncProfile();
    notifyListeners();
  }

  void toggleInvite(String k) {
    invited[k] = !(invited[k] ?? false);
    _syncProfile();
    notifyListeners();
  }
  void toggleCheck(String k) {
    checked[k] = !(checked[k] ?? false);
    _syncProfile();
    notifyListeners();
  }
  void setPlanTrail(int i) {
    planTrail = i;
    _syncProfile();
    notifyListeners();
  }
  void setPlanDate(int d) {
    planDate = d;
    _syncProfile();
    notifyListeners();
  }
  void openStamp(int? i) { stampIdx = stampIdx == i ? null : i; notifyListeners(); }
  void selectGear(String? id) { gearSel = gearSel == id ? null : id; notifyListeners(); }

  /// "REGISTRAR SAÍDA" na tela de equipamento — a única ação que muda
  /// uso/desgaste hoje (ver GearUsage.logOuting).
  void logGearOuting(String id) {
    final unit = gearData.firstWhere((g) => g.id == id).unit;
    gear[id] = gearUsage(id).logOuting(unit);
    _unlock('primeira_saida_equip');
    _syncProfile();
    notifyListeners();
  }
  void cheer() { cheered = !cheered; notifyListeners(); }
  void setDraft(String v) { draft = v; notifyListeners(); }

  void send() {
    if (draft.trim().isEmpty) return;
    msgs = [...msgs, Msg('VOCÊ', '08:31', draft.trim(), true)];
    draft = '';
    _unlock('primeira_mensagem');
    _syncProfile();
    notifyListeners();
  }

  /// Conclui a travessia: soma o desnível real e abre o resumo.
  void finish() {
    elev = (elev + 1640).clamp(0, elevGoal);
    pending = elev >= elevGoal;
    attrs = [
      for (var i = 0; i < attrs.length; i++) attrs[i].bump(deltas[i])
    ];
    _syncProfile();
    go('summary');
  }

  /// Reavaliação física: rank sobe, nível sobe, atributos ganham de novo.
  /// Compartilhado por fileRecord() (meta batida) e demoRankUp() (manual).
  void _advanceRank() {
    prevRank = ranks[rankIdx];
    rankIdx = (rankIdx + 1).clamp(0, 5);
    level += 1;
    attrs = [
      for (var i = 0; i < attrs.length; i++) attrs[i].bump(deltas[i])
    ];
    _unlock('rank_up');
  }

  /// Arquiva o registro. Se a meta caiu, dispara a reavaliação de rank.
  /// Recados usados em campo e ainda não confirmados travam o arquivamento
  /// — a dívida de confirmação precisa ser resolvida primeiro.
  void fileRecord() {
    if (relayDebts.isNotEmpty) return;
    if (pending) {
      _advanceRank();
      elev = 0;
      pending = false;
      _syncProfile();
      go('rankup');
    } else {
      go('profile');
    }
  }

  /// "SOLICITAR REAVALIAÇÃO DE RANK" no caderno — reavalia sob demanda,
  /// fora do ciclo normal de meta batida.
  void demoRankUp() {
    _advanceRank();
    _syncProfile();
    go('rankup');
  }

  /// Tela de ajustes: grava identidade, meta e unidades no caderno.
  void saveSettings({
    required String name,
    required String baseName,
    required int elevGoal,
    required String units,
    required String bio,
    required String photoUrl,
    required String coverUrl,
    required String instagram,
    required String strava,
    required String youtube,
    required String website,
    required String practicingSince,
    required String dreamTrail,
    required String favoriteGear,
  }) {
    this.name = name.trim().isEmpty ? this.name : name.trim();
    this.baseName = baseName.trim();
    this.elevGoal = elevGoal.clamp(2000, 12000);
    this.units = units;
    this.bio = bio.trim();
    this.photoUrl = photoUrl.trim();
    this.coverUrl = coverUrl.trim();
    socialLinks
      ..clear()
      ..addAll({
        if (instagram.trim().isNotEmpty) 'instagram': instagram.trim(),
        if (strava.trim().isNotEmpty) 'strava': strava.trim(),
        if (youtube.trim().isNotEmpty) 'youtube': youtube.trim(),
        if (website.trim().isNotEmpty) 'website': website.trim(),
      });
    this.practicingSince = practicingSince.trim();
    this.dreamTrail = dreamTrail.trim();
    this.favoriteGear = favoriteGear.trim();
    _syncProfile();
    go('profile');
  }
}
