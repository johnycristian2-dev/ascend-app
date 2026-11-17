import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../data/cordada_catalog.dart';
import '../data/friends_catalog.dart';
import '../data/gear_catalog.dart';
import '../geo/gpx_parser.dart';
import '../geo/track_recorder.dart';
import '../data/relay_notes.dart';
import '../data/weather_forecast.dart';
import '../data/trail_catalog.dart';
import '../models/attr_model.dart';
import '../models/catalog_trail_model.dart';
import '../models/chat_message_model.dart';
import '../models/gear_usage_model.dart';
import '../models/log_entry_model.dart';
import '../models/radio_message_model.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';
import '../services/location_service.dart';
import '../services/radio_service.dart';
import '../services/trail_repository.dart';
import 'expedition_calculator.dart';

export '../models/attr_model.dart' show Attr;
export '../models/chat_message_model.dart' show Msg;
export '../models/gear_usage_model.dart' show GearUsage;
export '../models/log_entry_model.dart' show LogEntry;
export '../models/radio_message_model.dart' show RadioMessage;

const ranks = ['E', 'D', 'C', 'B', 'A', 'S'];

/// Estado global. As telas de decisão escrevem aqui; todo o resto é derivado.
class ExpeditionState extends ChangeNotifier {
  ExpeditionState(
      {AuthService? auth,
      ProfileRepository? profiles,
      RadioService? radioService,
      TrailRepository? trails,
      LocationService? location,
      this.friendAcceptDelay = const Duration(seconds: 2)})
      : auth = auth ?? AuthService(),
        profiles = profiles ?? ProfileRepository(),
        radioService = radioService ?? RadioService(),
        trails = trails ?? TrailRepository(),
        location = location ?? LocationService();

  /// Serviços de backend — a UI só fala com eles através dos métodos
  /// abaixo (signIn/signUp/signOut/completeOnboarding), nunca direto.
  final AuthService auth;
  final ProfileRepository profiles;
  final RadioService radioService;
  final TrailRepository trails;
  final LocationService location;
  final AudioPlayer _player = AudioPlayer();

  /// Atraso até uma pessoa fictícia "aceitar" um pedido de amizade enviado.
  final Duration friendAcceptDelay;
  final List<Timer> _friendTimers = [];

  @override
  void dispose() {
    _fixSub?.cancel();
    _radioTimer?.cancel();
    for (final t in _friendTimers) {
      t.cancel();
    }
    _player.dispose();
    radioService.dispose();
    super.dispose();
  }

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

  /// XP acumulado real, pela fórmula de `xpGanho` (ver expedition_calculator.dart)
  /// — nunca somado diretamente na UI, só por travessias concluídas (`finish`).
  /// Baseline de demonstração coerente com `rankIdx = 3` (B: 7.000–14.999).
  int xpTotal = 9400;

  /// Maior altimetria ganha (em metros) numa única travessia concluída —
  /// é um recorde, não uma soma (ver `attrGains`). Baseline coerente com
  /// a travessia de demonstração já em andamento (`baseM` em
  /// expedition_calculator.dart).
  int recordAltimetriaM = baseM;

  /// Ganho real da ÚLTIMA travessia concluída (`finish()`), só para a
  /// tela de resumo exibir — nunca persistido, nunca somado de novo.
  int lastXpGain = 0;
  int lastElevGain = 0;
  AttrGains lastAttrGains = const AttrGains(0, 0, 0);
  bool lastAltitudeRecord = false;

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

  List<Msg> msgs = List.of(seedMsgs);

  /// Diário de bordo: notas escritas em campo, uma linha por trecho.
  List<LogEntry> logEntries = [];
  String logDraft = '';

  /// Recados de rádio — gravação de verdade (ver `radio_service.dart`),
  /// ao contrário do resto dos dados de demonstração do app.
  List<RadioMessage> radios = [];
  bool radioRecording = false;

  /// Segundos gravados nesta tomada (0 a 10 — o protótipo limita a 10 s).
  int radioRecSec = 0;
  String? radioError;

  /// `id` da mensagem tocando agora, se houver — ver `playRadio`.
  String? radioPlayingId;
  Timer? _radioTimer;

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
    final cat = todosEquip.firstWhere((g) => g.id == id);
    return GearUsage(uses: cat.uses, wear: cat.wear, od: cat.od);
  }

  // -------------------------------------------------------------- comandos

  static const depth = {
    'splash': 0, 'auth': 0, 'onboard': 1, 'home': 1, 'chat': 1, 'profile': 1, 'inv': 1,
    'ach': 2, 'history': 2, 'settings': 2, 'discover': 2, 'route': 2,
    'plan': 2, 'watch': 2, 'relay': 2, 'cordadas': 2, 'friends': 2, 'novoEquip': 2, 'novaCordada': 3, 'publish': 3, 'party': 3, 'summary': 3, 'window': 3,
    'rankup': 4, 'pack': 4,
  };

  /// Aba raiz destacada para telas mais profundas. `inv` virou aba própria
  /// na barra inferior — deixou de ser filha de `profile` (ver BottomNav).
  String get activeTab {
    const toHome = ['route', 'discover', 'publish', 'party', 'plan', 'watch', 'window', 'pack', 'relay'];
    const toProfile = ['rankup', 'summary', 'settings', 'history', 'ach'];
    if (toHome.contains(screen)) return 'home';
    if (toProfile.contains(screen)) return 'profile';
    if (screen == 'novoEquip') return 'inv';
    if (screen == 'cordadas' || screen == 'friends' || screen == 'novaCordada') return 'chat';
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
    xpTotal = p.xpTotal;
    recordAltimetriaM = p.recordAltimetriaM;
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
    logEntries = p.logEntries;
    radios = p.radios;
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
    savedTrack = [
      for (var i = 0; i + 1 < p.lastTrack.length; i += 2) GeoPoint(p.lastTrack[i], p.lastTrack[i + 1]),
    ];
    savedTrackKm = p.lastTrackKm;
    cordadaId = p.cordadaId;
    friends = List.of(p.friends);
    friendsIn = List.of(p.friendsIn);
    friendsOut = List.of(p.friendsOut);
    customCordadas = p.customCordadas.map(_cordadaDeMapa).whereType<Cordada>().toList();
    customGear = p.customGear.map(GearItem.fromMap).whereType<GearItem>().toList();
    gpxTrailId = p.gpxTrailId;
    gpxTrack = [
      for (var i = 0; i + 1 < p.gpxTrack.length; i += 2) GeoPoint(p.gpxTrack[i], p.gpxTrack[i + 1]),
    ];
    activeTrail = p.activeTrail.isEmpty
        ? trailCatalogSeed.first
        : CatalogTrail.fromMap((p.activeTrail['id'] as String?) ?? 'active', p.activeTrail);
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
      'xpTotal': xpTotal,
      'recordAltimetriaM': recordAltimetriaM,
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
      'logEntries': logEntries.map((e) => e.toMap()).toList(),
      'radios': radios.map((r) => r.toMap()).toList(),
      'gear': gear.map((k, v) => MapEntry(k, v.toMap())),
      'unlockedAchievements': unlockedAchievements.toList(),
      'photoUrl': photoUrl,
      'coverUrl': coverUrl,
      'bio': bio,
      'socialLinks': socialLinks,
      'practicingSince': practicingSince,
      'dreamTrail': dreamTrail,
      'favoriteGear': favoriteGear,
      'lastTrack': [for (final g in savedTrack) ...[g.lat, g.lon]],
      'lastTrackKm': savedTrackKm,
      'cordadaId': cordadaId,
      'friends': friends,
      'friendsIn': friendsIn,
      'friendsOut': friendsOut,
      'customCordadas': [
        for (final c in customCordadas)
          {
            'id': c.id,
            'nome': c.nome,
            'trilha': c.trilha,
            'membros': [for (final m in c.membrosIds) m],
          }
      ],
      'customGear': [for (final g in customGear) g.toMap()],
      'gpxTrailId': gpxTrailId,
      'gpxTrack': [for (final g in gpxTrack) ...[g.lat, g.lon]],
      'activeTrail': {'id': activeTrail.id, ...activeTrail.toMap()},
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
  void confirmSos() {
    sosSent = true;
    _postSos('SOS ACIONADO · preciso de ajuda. Posição enviada: 22°23\'S 44°40\'W, 2 421 m.');
    notifyListeners();
  }

  /// Texto do SOS que foi para a cordada (mostrado também na tela de SOS).
  String? get sosMessage {
    for (final m in msgs.reversed) {
      if (m.sos && m.me) return m.text;
    }
    return null;
  }

  /// Cancelar o alerta avisa a cordada de que está tudo bem.
  void cancelSos() {
    if (sosSent) _postSos('SOS CANCELADO · estou seguro.');
    closeSos();
  }

  static String _agora() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }

  void _postSos(String texto) {
    msgs = [...msgs, Msg('VOCÊ', _agora(), texto, true, sos: true)];
    _syncProfile();
  }

  // ---- equipamento cadastrado pelo usuário
  List<GearItem> customGear = [];
  List<GearItem> get todosEquip => [...gearData, ...customGear];

  /// Cadastra uma peça. Devolve um texto de erro ou null.
  String? cadastrarEquip({
    required String nome,
    required String categoria,
    required String pesoKg,
    String detalhe = '',
    String limite = '',
    bool emKm = false,
  }) {
    final n = nome.trim();
    if (n.isEmpty) return 'Dê um nome à peça.';
    final kg = double.tryParse(pesoKg.trim().replaceAll(',', '.'));
    if (kg == null || kg < 0 || kg > 60) return 'Peso inválido (use kg, ex.: 1,2).';
    final lim = int.tryParse(limite.trim()) ?? 50;
    if (lim <= 0) return 'O limite de uso precisa ser maior que zero.';
    final kgTxt = kg.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '').replaceAll('.', ',');
    final id = 'meu-${DateTime.now().microsecondsSinceEpoch}';
    final spec = [if (detalhe.trim().isNotEmpty) detalhe.trim(), '$kgTxt kg'].join(' · ');
    customGear = [
      ...customGear,
      GearItem.custom(
          id: id, nome: n, spec: spec, tag: categoria, kg: kgTxt, lim: lim, unit: emKm ? 'km' : 'saídas'),
    ];
    gearSel = id;
    _syncProfile();
    notifyListeners();
    return null;
  }

  void removerEquip(String id) {
    customGear = customGear.where((g) => g.id != id).toList();
    gear.remove(id);
    if (gearSel == id) gearSel = null;
    _syncProfile();
    notifyListeners();
  }

  /// Enquanto true, todas as trilhas do catálogo ficam liberadas
  /// independente do rank (pedido para a demonstração). Volte para false
  /// para reativar o bloqueio por rank.
  static const trilhasLiberadas = true;
  bool trilhaBloqueada(CatalogTrail t) => !trilhasLiberadas && t.rankIdx > rankIdx;

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
  // ----------------------------------------------------- GPS em tempo real

  /// GPS ligado: acompanha sua posição e grava o traçado da subida.
  bool tracking = false;
  GeoPoint? myPos;
  String? locationError;
  final TrackRecorder recorder = TrackRecorder();
  StreamSubscription<LocationFix>? _fixSub;

  /// Último traçado salvo no caderno (para mostrar depois de parar o GPS).
  List<GeoPoint> savedTrack = const [];
  double savedTrackKm = 0;

  /// Traçado a desenhar: o que está sendo gravado, ou o último salvo.
  List<GeoPoint> get shownTrack => tracking || recorder.points.isNotEmpty ? recorder.points : savedTrack;
  double get shownTrackKm => tracking || recorder.points.isNotEmpty ? recorder.km : savedTrackKm;

  Future<void> startTracking() async {
    if (tracking) return;
    locationError = null;
    final problem = await location.ensurePermission();
    if (problem != null) {
      locationError = problem;
      notifyListeners();
      return;
    }
    recorder.clear();
    tracking = true;
    _fixSub = location.fixes().listen((fix) {
      myPos = fix.point;
      recorder.add(fix.point, accuracyM: fix.accuracyM);
      notifyListeners();
    }, onError: (_) {
      locationError = 'Perdi o sinal de GPS.';
      notifyListeners();
    });
    notifyListeners();
  }

  /// Para o GPS e salva o traçado gravado no caderno.
  Future<void> stopTracking() async {
    await _fixSub?.cancel();
    _fixSub = null;
    tracking = false;
    if (recorder.points.length >= 2) {
      savedTrack = recorder.downsampled(600);
      savedTrackKm = recorder.km;
      _syncProfile();
    }
    notifyListeners();
  }

  // -------------------------------------------------------------- cordada

  /// Cordada em que o usuário está ('' = nenhuma). DEMONSTRAÇÃO: integrantes
  /// fictícios (ver cordada_catalog.dart) — não há convite nem conta real.
  String cordadaId = 'sul';

  /// Cordadas montadas pelo usuário com seus amigos.
  List<Cordada> customCordadas = [];

  List<Cordada> get todasCordadas => [...cordadasDemo, ...customCordadas];

  Cordada? get cordada {
    for (final c in todasCordadas) {
      if (c.id == cordadaId) return c;
    }
    return null;
  }

  Cordada? _cordadaDeMapa(Map<String, dynamic> m) {
    final ids = ((m['membros'] as List?) ?? const []).map((e) => e as String).toList();
    final membros = _membros(ids);
    if (membros.isEmpty) return null;
    return Cordada((m['id'] as String?) ?? 'c-x', (m['nome'] as String?) ?? 'MINHA CORDADA',
        (m['trilha'] as String?) ?? '', 'Criada por você', membros,
        membrosIds: ids);
  }

  List<CordadaMember> _membros(List<String> ids) =>
      ids.map(pessoaPorId).whereType<Person>().map((p) => p.comoMembro()).toList();

  /// Cria uma cordada só com amigos e já entra nela.
  void criarCordada(String nome, List<String> amigos) {
    final ids = [for (final id in amigos) if (friends.contains(id)) id];
    if (ids.isEmpty) return;
    final limpo = nome.trim().isEmpty ? 'MINHA CORDADA' : nome.trim().toUpperCase();
    final c = Cordada('c-${DateTime.now().millisecondsSinceEpoch}', limpo, activeTrail.nome,
        'Criada por você', _membros(ids),
        membrosIds: ids);
    customCordadas = [...customCordadas, c];
    cordadaId = c.id;
    _syncProfile();
    go('chat');
  }

  // ---------------------------------------------------------------- amigos

  /// DEMONSTRAÇÃO: pessoas fictícias (friends_catalog.dart). Os pedidos
  /// enviados são "aceitos" sozinhos após [friendAcceptDelay], só para
  /// mostrar o fluxo — não há ninguém do outro lado.
  List<String> friends = ['kai', 'nina', 'teo'];
  List<String> friendsIn = ['mai', 'bia'];
  List<String> friendsOut = [];

  bool ehAmigo(String id) => friends.contains(id);

  void aceitarPedido(String id) {
    if (!friendsIn.contains(id)) return;
    friendsIn = [for (final x in friendsIn) if (x != id) x];
    if (!friends.contains(id)) friends = [...friends, id];
    _syncProfile();
    notifyListeners();
  }

  void recusarPedido(String id) {
    friendsIn = [for (final x in friendsIn) if (x != id) x];
    _syncProfile();
    notifyListeners();
  }

  void pedirAmizade(String id) {
    if (pessoaPorId(id) == null || friends.contains(id) || friendsOut.contains(id)) return;
    friendsOut = [...friendsOut, id];
    _syncProfile();
    notifyListeners();
    _friendTimers.add(Timer(friendAcceptDelay, () {
      if (!friendsOut.contains(id)) return; // cancelado
      friendsOut = [for (final x in friendsOut) if (x != id) x];
      friends = [...friends, id];
      _syncProfile();
      notifyListeners();
    }));
  }

  void cancelarPedido(String id) {
    friendsOut = [for (final x in friendsOut) if (x != id) x];
    _syncProfile();
    notifyListeners();
  }

  void removerAmigo(String id) {
    friends = [for (final x in friends) if (x != id) x];
    _syncProfile();
    notifyListeners();
  }

  void entrarCordada(String id) {
    if (!todasCordadas.any((c) => c.id == id)) return;
    cordadaId = id;
    _syncProfile();
    go('chat');
  }

  void sairCordada() {
    cordadaId = '';
    _syncProfile();
    notifyListeners();
  }

  // ------------------------------------------------ traçado GPX importado

  /// Traçado GPX que o usuário importou, e a trilha a que pertence.
  String gpxTrailId = '';
  List<GeoPoint> gpxTrack = const [];

  /// O traçado importado só vale para a trilha para a qual foi importado.
  List<GeoPoint> get activeGpx => gpxTrailId == activeTrail.id ? gpxTrack : const [];
  double get activeGpxKm => trackLengthKm(activeGpx);

  /// Lê um GPX e o associa à trilha em curso. Devolve uma mensagem de erro,
  /// ou null se deu certo. Nunca inventa pontos: GPX sem trilha é recusado.
  String? importGpx(String xml) {
    final pts = parseGpx(xml);
    if (pts.length < 2) return 'Não encontrei um traçado nesse arquivo (precisa de pontos <trkpt> ou <rtept>).';
    const max = 800;
    final out = <GeoPoint>[];
    if (pts.length <= max) {
      out.addAll(pts);
    } else {
      for (var i = 0; i < max; i++) {
        out.add(pts[(i * (pts.length - 1) / (max - 1)).round()]);
      }
    }
    gpxTrailId = activeTrail.id;
    gpxTrack = out;
    _syncProfile();
    notifyListeners();
    return null;
  }

  void removerGpx() {
    gpxTrailId = '';
    gpxTrack = const [];
    _syncProfile();
    notifyListeners();
  }

  // ------------------------------------------------------------- catálogo

  /// A trilha em curso — a que a tela inicial, o mapa, o plano e o XP usam.
  CatalogTrail activeTrail = trailCatalogSeed.first;

  /// Distância e desnível da expedição: os da trilha escolhida + o efeito
  /// das decisões de mochila (variantes de rota) sobre a rota-base.
  double get activeKm => activeTrail.km + (core.km - baseKm);
  int get activeM => activeTrail.ganhoM + (core.m - baseM);

  /// Escolhe uma trilha do catálogo como a expedição em curso e segue
  /// para o planejamento (data e cordada).
  void selectTrail(CatalogTrail t) {
    activeTrail = t;
    _syncProfile();
    go('plan');
  }

  /// Uma leitura única de GPS, para marcar o local de uma trilha a publicar.
  Future<GeoPoint?> currentLocation() async {
    final problem = await location.ensurePermission();
    if (problem != null) {
      locationError = problem;
      notifyListeners();
      return null;
    }
    try {
      final fix = await location.fixes().first.timeout(const Duration(seconds: 20));
      return fix.point;
    } catch (_) {
      locationError = 'Não consegui ler sua posição agora.';
      notifyListeners();
      return null;
    }
  }

  /// Curadoria embutida + trilhas da comunidade (mais novas primeiro).
  List<CatalogTrail> catalog = List.of(trailCatalogSeed);
  bool catalogLoading = false;

  /// true quando a coleção da comunidade não pôde ser lida (sem rede ou
  /// regras do Firestore ainda não publicadas) — a lista mostra só a curadoria.
  bool catalogOffline = false;
  String? publishError;

  Future<void> loadCatalog() async {
    catalogLoading = true;
    notifyListeners();
    try {
      final community = await trails.fetchAll();
      catalog = [...community, ...trailCatalogSeed];
      catalogOffline = false;
    } catch (_) {
      catalog = List.of(trailCatalogSeed);
      catalogOffline = true;
    }
    catalogLoading = false;
    notifyListeners();
  }

  /// Publica uma trilha no catálogo, em nome do usuário logado. Devolve
  /// true se a coleção aceitou (e já recarrega a lista).
  Future<bool> publishTrail({
    required String nome,
    required int rankIdx,
    required double km,
    required int ganhoM,
    required String duracao,
    required String regiao,
    required String nota,
    double? lat,
    double? lon,
  }) async {
    publishError = null;
    final id = uid;
    if (id == null) {
      publishError = 'Entre na sua conta para publicar.';
    } else if (nome.trim().isEmpty || nome.trim().length > 80) {
      publishError = 'Dê um nome à trilha (até 80 caracteres).';
    } else if (km <= 0) {
      publishError = 'Informe a distância em km.';
    }
    if (publishError != null) {
      notifyListeners();
      return false;
    }
    try {
      await trails.publish(CatalogTrail(
        id: '',
        nome: nome.trim().toUpperCase(),
        rankIdx: rankIdx.clamp(0, 5),
        km: km,
        ganhoM: ganhoM < 0 ? 0 : ganhoM,
        duracao: duracao.trim(),
        regiao: regiao.trim(),
        nota: nota.trim(),
        autorNome: name,
        autorUid: id!,
        fonte: 'comunidade',
        criadoEmMs: DateTime.now().millisecondsSinceEpoch,
        lat: lat,
        lon: lon,
      ));
    } catch (_) {
      publishError = 'Não foi possível publicar agora. Confira a conexão e tente de novo.';
      notifyListeners();
      return false;
    }
    await loadCatalog();
    return true;
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
    final unit = todosEquip.firstWhere((g) => g.id == id).unit;
    gear[id] = gearUsage(id).logOuting(unit);
    _unlock('primeira_saida_equip');
    _syncProfile();
    notifyListeners();
  }
  void cheer() { cheered = !cheered; notifyListeners(); }
  void setDraft(String v) { draft = v; notifyListeners(); }

  void setLogDraft(String v) {
    logDraft = v.length > 180 ? v.substring(0, 180) : v;
    notifyListeners();
  }

  /// "REGISTRAR" no diário de bordo — uma linha sobre o trecho onde você
  /// está agora (modo campo). Segmento fixo por ora, como no protótipo
  /// (`VALE DAS PEDRAS`): o app ainda não deriva o nome do trecho atual
  /// a partir de uma posição de verdade.
  void sendLogEntry() {
    final t = logDraft.trim();
    if (t.isEmpty) return;
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    logEntries = [...logEntries, LogEntry('VALE DAS PEDRAS', time, t)];
    logDraft = '';
    _unlock('primeira_nota_diario');
    _syncProfile();
    notifyListeners();
  }

  /// "Mantenha pressionado" no rádio de cordada — grava de verdade (ver
  /// `radio_service.dart`), até 10 s, como no protótipo. Web apenas por
  /// ora: é a única plataforma que dá pra testar sem SDK nativo aqui.
  Future<void> startRadioRecording() async {
    radioError = null;
    if (!kIsWeb) {
      radioError = 'Gravação só funciona na versão web deste app por enquanto.';
      notifyListeners();
      return;
    }
    if (!await radioService.hasPermission()) {
      radioError = 'Permissão de microfone negada — ative nas configurações do navegador.';
      notifyListeners();
      return;
    }
    try {
      await radioService.start();
    } catch (_) {
      radioError = 'Não deu para começar a gravar. Tente de novo.';
      notifyListeners();
      return;
    }
    radioRecording = true;
    radioRecSec = 0;
    notifyListeners();
    _radioTimer?.cancel();
    _radioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      radioRecSec++;
      if (radioRecSec >= 10) {
        timer.cancel();
        stopRadioRecording();
      } else {
        notifyListeners();
      }
    });
  }

  /// Solta o botão: fecha a gravação e pina o recado no topo da lista
  /// (`pinRadio` no protótipo) — mínimo de 1 s, pra não gravar vazio.
  Future<void> stopRadioRecording() async {
    _radioTimer?.cancel();
    if (!radioRecording) return;
    final sec = radioRecSec.clamp(1, 10);
    radioRecording = false;
    radioRecSec = 0;
    try {
      final cap = await radioService.stop();
      if (cap != null && cap.bytes.isNotEmpty) {
        radios = [
          RadioMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            who: 'VOCÊ',
            at: 'SELA DOS DOIS IRMÃOS · 2 180 m',
            time: 'agora',
            durationSec: sec,
            audioBase64: cap.base64,
            mime: cap.mime,
            pending: true,
          ),
          ...radios,
        ];
        _unlock('primeiro_radio');
        _syncProfile();
      }
    } catch (_) {
      radioError = 'Não deu para salvar a gravação.';
    }
    notifyListeners();
  }

  /// Soltar antes de gravar nada de fato (ex.: permissão negou no meio).
  void cancelRadioRecording() {
    _radioTimer?.cancel();
    if (!radioRecording) return;
    radioRecording = false;
    radioRecSec = 0;
    radioService.cancel();
    notifyListeners();
  }

  /// Toca (ou para, se já for a que está tocando) um recado de rádio.
  Future<void> playRadio(RadioMessage m) async {
    if (radioPlayingId == m.id) {
      await _player.stop();
      radioPlayingId = null;
      notifyListeners();
      return;
    }
    radioPlayingId = m.id;
    notifyListeners();
    try {
      await _player.play(UrlSource('data:${m.mime};base64,${m.audioBase64}'));
      unawaited(_player.onPlayerComplete.first.then((_) {
        if (radioPlayingId == m.id) {
          radioPlayingId = null;
          notifyListeners();
        }
      }));
    } catch (_) {
      radioPlayingId = null;
      notifyListeners();
    }
  }

  void send() {
    if (draft.trim().isEmpty) return;
    msgs = [...msgs, Msg('VOCÊ', _agora(), draft.trim(), true)];
    draft = '';
    _unlock('primeira_mensagem');
    _syncProfile();
    notifyListeners();
  }

  /// Conclui a travessia: XP, desnível e atributos vêm da fórmula real do
  /// planejamento original, aplicada à rota REAL resultante das decisões
  /// da cordada (`core.km`/`core.m`) — não mais de um incremento fixo.
  /// Ver xpGanho/attrGains em expedition_calculator.dart.
  void finish() {
    final km = activeKm;
    final m = activeM;
    final dificuldade = dificuldadeDe(trail);
    final xpGain = xpGanho(km: km, m: m, dificuldade: dificuldade);
    xpTotal += xpGain;

    final gains = attrGains(km: km, m: m, tecnica: isTecnica(trail));
    final novoRecorde = m > recordAltimetriaM;
    attrs = [
      attrs[0].bump(gains.resistencia),
      attrs[1].bump(gains.forca),
      attrs[2].bump(gains.tecnica),
      // Altitude é um recorde, não uma soma: só bate se ESTA travessia
      // ganhou mais desnível que a melhor já registrada.
      if (novoRecorde) attrs[3].bump(3) else attrs[3],
    ];
    if (novoRecorde) recordAltimetriaM = m;

    // Guardado só para a tela de resumo mostrar o ganho de verdade desta
    // travessia, já que attrs/xpTotal acima já viraram o total acumulado.
    lastXpGain = xpGain;
    lastElevGain = m;
    lastAttrGains = gains;
    lastAltitudeRecord = novoRecorde;

    elev = (elev + m).clamp(0, elevGoal);
    pending = elev >= elevGoal;
    _syncProfile();
    go('summary');
  }

  /// Reavaliação: o rank passa a vir do XP acumulado real (`rankIdxForXp`),
  /// não mais de um incremento manual fixo — os atributos já foram
  /// atualizados em `finish()`, por isso não bate de novo aqui.
  /// Compartilhada por fileRecord() (meta batida) e demoRankUp() (manual).
  void _advanceRank() {
    prevRank = ranks[rankIdx];
    rankIdx = rankIdxForXp(xpTotal);
    level += 1;
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
