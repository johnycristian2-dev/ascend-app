import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ascend/frontend/app.dart';
import 'package:ascend/frontend/screens/home_screen.dart';
import 'package:ascend/frontend/widgets/route_map.dart';

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

  Future<void> pumpHome(WidgetTester t, Size size) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    final s = _novoEstado();
    await t.pumpWidget(MaterialApp(
      home: Expedition(notifier: s, child: const Scaffold(body: HomeScreen())),
    ));
    await t.pump(const Duration(milliseconds: 300));
  }

  testWidgets('home em tela alta: mapa ocupa a maior parte da altura', (t) async {
    await pumpHome(t, const Size(390, 800));
    expect(t.takeException(), isNull);
    final mapa = t.getSize(find.byType(RouteMap));
    expect(mapa.height, greaterThan(800 * 0.55));
  });

  testWidgets('home em tela baixa não estoura o layout', (t) async {
    await pumpHome(t, const Size(390, 500));
    expect(t.takeException(), isNull);
    expect(t.getSize(find.byType(RouteMap)).height, greaterThanOrEqualTo(300));
  });
}
