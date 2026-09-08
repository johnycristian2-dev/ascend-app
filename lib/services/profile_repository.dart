import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Fina camada sobre o Firestore — o caderno de expedição de cada usuário
/// mora em `users/{uid}`. Ninguém fora daqui monta uma `CollectionReference`.
class ProfileRepository {
  final FirebaseFirestore _db;
  ProfileRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  Future<UserProfile?> fetch(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromMap(uid, snap.data()!);
  }

  Future<void> create(UserProfile profile) =>
      _doc(profile.uid).set(profile.toMap());

  /// Grava só os campos que mudaram — evita sobrescrever o documento
  /// inteiro quando, por exemplo, só o nome de campo mudou.
  Future<void> update(String uid, Map<String, dynamic> patch) =>
      _doc(uid).set(patch, SetOptions(merge: true));
}
