import 'package:flutter/foundation.dart';
import '../data/relay_notes.dart';
import '../data/weather_forecast.dart';
import '../models/attr_model.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';
import 'expedition_calculator.dart';

export '../models/attr_model.dart' show Attr;

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

  /// Modo campo: tela cheia de instrumento, acessível a partir do mapa.
  bool fieldMode = false;

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

  List<Msg> msgs = [
    const Msg('KAI', '08:12', 'Saindo do abrigo agora. Vento forte na crista norte.', false),
    const Msg('VOCÊ', '08:14', 'Copiado. Levo a corda extra de 60 m.', true),
    const Msg('NINA', '08:20', 'Chego no ponto 2 em 40 min. Marquem no mapa.', false),
  ];

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
    }).catchError((_) {});
  }

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
        await profiles.create(UserProfile.starter(uid: id, name: name, rankIdx: rankIdx)
            .copyWith(baseName: baseName));
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

  void pickWx(int i) { wxPick = i; notifyListeners(); }
  void setTrail(TrailState t) { trail = t; notifyListeners(); }

  /// Modo campo é uma sobreposição, não uma tela do fluxo — como no protótipo.
  void enterField() { fieldMode = true; notifyListeners(); }
  void exitField() { fieldMode = false; notifyListeners(); }

  void toggleCarry(String nome) {
    packOut.contains(nome) ? packOut.remove(nome) : packOut.add(nome);
    notifyListeners();
  }

  void voteRelay(int i, String v) {
    relayVote[i] = relayVote[i] == v ? null : v;
    notifyListeners();
  }

  void pickPin(int? i) {
    relaySel = relaySel == i ? null : i;
    // Abrir um recado em campo é usá-lo — a confirmação vira uma dívida.
    if (relaySel != null) relayUsed.add(relaySel!);
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
    notifyListeners();
  }

  void toggleInvite(String k) {
    invited[k] = !(invited[k] ?? false);
    notifyListeners();
  }
  void toggleCheck(String k) {
    checked[k] = !(checked[k] ?? false);
    notifyListeners();
  }
  void setPlanTrail(int i) { planTrail = i; notifyListeners(); }
  void setPlanDate(int d) { planDate = d; notifyListeners(); }
  void openStamp(int? i) { stampIdx = stampIdx == i ? null : i; notifyListeners(); }
  void selectGear(String? id) { gearSel = gearSel == id ? null : id; notifyListeners(); }
  void cheer() { cheered = !cheered; notifyListeners(); }
  void setDraft(String v) { draft = v; notifyListeners(); }

  void send() {
    if (draft.trim().isEmpty) return;
    msgs = [...msgs, Msg('VOCÊ', '08:31', draft.trim(), true)];
    draft = '';
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
  }) {
    this.name = name.trim().isEmpty ? this.name : name.trim();
    this.baseName = baseName.trim();
    this.elevGoal = elevGoal.clamp(2000, 12000);
    this.units = units;
    _syncProfile();
    go('profile');
  }
}

class Msg {
  final String who, time, text;
  final bool me;
  const Msg(this.who, this.time, this.text, this.me);
}
