import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ascend/frontend/app.dart';
import 'package:ascend/frontend/screens/chat_screen.dart';
import 'package:ascend/frontend/screens/cordadas_screen.dart';
import 'package:ascend/frontend/screens/friends_screen.dart';
import 'package:ascend/frontend/screens/new_gear_screen.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/backend/services/auth_service.dart';
import 'package:ascend/backend/services/profile_repository.dart';
import 'package:ascend/backend/models/catalog_trail_model.dart';
import 'package:ascend/backend/services/location_service.dart';
import 'package:ascend/backend/services/radio_service.dart';
import 'package:ascend/backend/services/trail_repository.dart';
import 'package:ascend/backend/state/expedition_state.dart';

// Dublês que não tocam em Firebase nem no microfone: o estado só os usa
// quando há uid logado, o que não é o caso nestes testes (uid == null, então
// _syncProfile() retorna cedo).
class _FakeAuth implements AuthService {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeProfiles implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeRadio implements RadioService {
  @override
  void dispose() {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeTrails implements TrailRepository {
  final List<CatalogTrail> store = [];
  bool falha = false;
  @override
  Future<List<CatalogTrail>> fetchAll() async {
    if (falha) throw Exception('sem rede');
    return List.of(store);
  }

  @override
  Future<void> publish(CatalogTrail t) async {
    if (falha) throw Exception('sem rede');
    store.insert(0, t);
  }
}

class _FakeLocation implements LocationService {
  String? problema;
  final ctrl = StreamController<LocationFix>();
  @override
  Future<String?> ensurePermission() async => problema;
  @override
  Stream<LocationFix> fixes() => ctrl.stream;
}

ExpeditionState _novoEstado([_FakeTrails? trails, _FakeLocation? loc]) => ExpeditionState(
    location: loc ?? _FakeLocation(),
    auth: _FakeAuth(),
    profiles: _FakeProfiles(),
    radioService: _FakeRadio(),
    trails: trails ?? _FakeTrails());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final canal in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers']) {
      messenger.setMockMethodCallHandler(MethodChannel(canal), (_) async => null);
    }
  });

  Future<ExpeditionState> pump(WidgetTester t, Widget tela) async {
    t.view.physicalSize = const Size(390, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    final s = _novoEstado();
    await t.pumpWidget(MaterialApp(home: Expedition(notifier: s, child: Scaffold(body: tela))));
    await t.pump();
    return s;
  }

  testWidgets('cordada mostra os integrantes fictícios e o botão de sair', (t) async {
    await pump(t, const ChatScreen());
    expect(t.takeException(), isNull);
    expect(find.text('CORDADA SUL'), findsOneWidget);
    expect(find.text('KAI'), findsWidgets);
    expect(find.text('NINA'), findsWidgets);
    expect(find.text('SAIR DA CORDADA'), findsOneWidget);
  });

  testWidgets('sair da cordada leva ao estado "sem cordada"; entrar volta', (t) async {
    final s = await pump(t, const ChatScreen());
    await t.tap(find.text('SAIR DA CORDADA'));
    await t.pump();
    expect(s.cordada, isNull);
    expect(find.text('Sem cordada.'), findsOneWidget);
    expect(find.text('VER CORDADAS'), findsOneWidget);
  });

  testWidgets('lista de cordadas permite entrar em outra', (t) async {
    final s = await pump(t, const CordadasScreen());
    expect(t.takeException(), isNull);
    expect(find.text('MADRUGADORES'), findsOneWidget);
    await t.ensureVisible(find.text('ENTRAR NESTA CORDADA').first);
    await t.tap(find.text('ENTRAR NESTA CORDADA').first);
    await t.pump();
    expect(s.cordadaId, isNot('sul'));
    expect(s.cordada, isNotNull);
  });

  testWidgets('tela de amigos aceita pedido e leva a criar cordada', (t) async {
    final s = await pump(t, const FriendsScreen());
    expect(t.takeException(), isNull);
    expect(find.text('PEDIDOS RECEBIDOS'), findsOneWidget);
    await t.tap(find.text('ACEITAR').first);
    await t.pump();
    expect(s.friends.length, 4);
    expect(find.text('CRIAR CORDADA COM AMIGOS'), findsOneWidget);
  });

  testWidgets('cadastro de equipamento aparece no inventário', (t) async {
    final s = await pump(t, const NewGearScreen());
    expect(t.takeException(), isNull);
    await t.enterText(find.byType(TextField).first, 'Jaqueta teste');
    await t.enterText(find.byType(TextField).at(2), '0,5');
    await t.ensureVisible(find.text('SALVAR EQUIPAMENTO'));
    await t.tap(find.text('SALVAR EQUIPAMENTO'));
    await t.pump();
    expect(s.customGear.single.nome, 'Jaqueta teste');
    expect(s.screen, 'inv');
  });

  testWidgets('SOS aparece como mensagem destacada no chat da cordada', (t) async {
    final s = await pump(t, const ChatScreen());
    s.confirmSos();
    await t.pump();
    expect(find.textContaining('SOS ACIONADO'), findsOneWidget);
  });
}
