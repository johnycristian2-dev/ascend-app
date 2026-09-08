import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'theme/ink.dart';
import 'theme/type.dart';
import 'state/expedition_state.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/screen_index.dart';
import 'screens/splash.dart';
import 'screens/auth.dart';
import 'screens/onboard.dart';
import 'screens/home.dart';
import 'screens/route.dart';
import 'screens/window.dart';
import 'screens/pack.dart';
import 'screens/relay.dart';
import 'screens/discover.dart';
import 'screens/plan.dart';
import 'screens/party.dart';
import 'screens/watch.dart';
import 'screens/chat.dart';
import 'screens/profile.dart';
import 'screens/inventory.dart';
import 'screens/achievements.dart';
import 'screens/history.dart';
import 'screens/settings.dart';
import 'screens/summary.dart';
import 'screens/rankup.dart';
import 'screens/field.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? initError;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    initError = e;
  }
  runApp(initError == null ? const AscendApp() : FirebaseSetupError(error: initError));
}

/// Tela de erro amigável quando `firebase_options.dart` ainda é o placeholder
/// (ou o Firebase não foi configurado direito) — em vez de a tela branca
/// da morte, diz exatamente o que fazer.
class FirebaseSetupError extends StatelessWidget {
  final Object error;
  const FirebaseSetupError({required this.error, super.key});

  @override
  Widget build(BuildContext c) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: Ink_.bg),
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FIREBASE NÃO CONFIGURADO',
                      style: T.num(size: 24, color: Ink_.amber)),
                  const SizedBox(height: 14),
                  Text(
                    'lib/firebase_options.dart ainda tem os valores de exemplo. '
                    'Crie o projeto no console do Firebase e rode `flutterfire configure` '
                    '(passo a passo no README.md) antes de rodar o app.',
                    style: T.body(size: 13, color: Ink_.text2),
                  ),
                  const SizedBox(height: 18),
                  Text('Erro original:', style: T.body(size: 10, color: Ink_.dim)),
                  const SizedBox(height: 4),
                  Text('$error', style: T.body(size: 10, color: Ink_.dim)),
                ],
              ),
            ),
          ),
        ),
      );
}

/// Injeta o estado sem dependência externa de gerenciamento de estado.
class Expedition extends InheritedNotifier<ExpeditionState> {
  const Expedition({required ExpeditionState super.notifier, required super.child, super.key});

  /// Assina as mudanças (use dentro de build).
  static ExpeditionState of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<Expedition>()!.notifier!;

  /// Lê sem assinar (use em initState e callbacks).
  static ExpeditionState readOf(BuildContext c) =>
      c.getInheritedWidgetOfExactType<Expedition>()!.notifier!;
}

class AscendApp extends StatefulWidget {
  const AscendApp({super.key});
  @override
  State<AscendApp> createState() => _AscendAppState();
}

class _AscendAppState extends State<AscendApp> {
  final state = ExpeditionState();
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    // A janela de 72 h corre em tempo real.
    timer = Timer.periodic(const Duration(seconds: 1), (_) => state.tickClock());
  }

  @override
  void dispose() {
    timer.cancel();
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Expedition(
        notifier: state,
        child: MaterialApp(
          title: 'Ascend',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Ink_.bg,
            colorScheme: const ColorScheme.dark(
              surface: Ink_.bg,
              primary: Ink_.amber,
              secondary: Ink_.green,
            ),
            textTheme: TextTheme(bodyMedium: T.body()),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          home: const Shell(),
        ),
      );
}

/// Casca única: troca a tela por estado (como no protótipo) e anima a direção.
class Shell extends StatelessWidget {
  const Shell({super.key});

  Widget _screen(String s) => switch (s) {
        'splash' => const SplashScreen(),
        'auth' => const AuthScreen(),
        'onboard' => const OnboardScreen(),
        'home' => const HomeScreen(),
        'route' => const RouteScreen(),
        'window' => const WindowScreen(),
        'pack' => const PackScreen(),
        'relay' => const RelayScreen(),
        'discover' => const DiscoverScreen(),
        'plan' => const PlanScreen(),
        'party' => const PartyScreen(),
        'watch' => const WatchScreen(),
        'chat' => const ChatScreen(),
        'profile' => const ProfileScreen(),
        'inv' => const InventoryScreen(),
        'ach' => const AchievementsScreen(),
        'history' => const HistoryScreen(),
        'settings' => const SettingsScreen(),
        'summary' => const SummaryScreen(),
        'rankup' => const RankUpScreen(),
        _ => const HomeScreen(),
      };

  @override
  Widget build(BuildContext c) {
    final s = Expedition.of(c);
    final chrome = s.screen != 'splash' && s.screen != 'auth' && s.screen != 'onboard';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ScreenSwitch(
                    back: s.back,
                    child: KeyedSubtree(
                      key: ValueKey('${s.screen}${s.empty}'),
                      child: _screen(s.screen),
                    ),
                  ),
                ),
                if (chrome) BottomNav(active: s.activeTab),
              ],
            ),
            // Modo campo é uma sobreposição, não uma tela do fluxo normal —
            // como no protótipo (não entra no mapa `depth`/`go`).
            if (s.fieldMode) const Positioned.fill(child: FieldScreen()),
          ],
        ),
      ),
      floatingActionButton: chrome && !s.fieldMode ? const ScreenIndexButton() : null,
    );
  }
}

/// Desliza a nova tela pela direita; volta pela esquerda.
class ScreenSwitch extends StatelessWidget {
  final Widget child;
  final bool back;
  const ScreenSwitch({required this.child, required this.back, super.key});

  @override
  Widget build(BuildContext c) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (w, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(
              begin: Offset(back ? -0.06 : 0.06, 0),
              end: Offset.zero,
            ).animate(a),
            child: w,
          ),
        ),
        layoutBuilder: (cur, prev) => Stack(
          alignment: Alignment.topCenter,
          children: [...prev, if (cur != null) cur],
        ),
        child: child,
      );
}
