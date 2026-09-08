import 'package:firebase_auth/firebase_auth.dart';

/// Fina camada sobre o Firebase Auth — a UI nunca fala com `FirebaseAuth`
/// direto, só com isto aqui.
class AuthService {
  final FirebaseAuth _auth;
  AuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User> signUp({required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    return cred.user!;
  }

  Future<User> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    return cred.user!;
  }

  Future<void> signOut() => _auth.signOut();

  /// Traduz os erros mais comuns do Firebase Auth para o tom do app —
  /// direto, sem jargão técnico.
  static String friendlyMessage(Object e) {
    if (e is! FirebaseAuthException) return 'Não foi possível entrar. Tente de novo.';
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com este e-mail.';
      case 'weak-password':
        return 'Senha muito curta — use pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão. Verifique a rede e tente de novo.';
      case 'too-many-requests':
        return 'Muitas tentativas. Espere um pouco e tente de novo.';
      default:
        return 'Não foi possível entrar (${e.code}).';
    }
  }
}
