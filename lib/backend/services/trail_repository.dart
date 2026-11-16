import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/catalog_trail_model.dart';

/// Trilhas publicadas pela comunidade — coleção `trails` (ver firestore.rules).
class TrailRepository {
  final FirebaseFirestore? _injected;
  TrailRepository([FirebaseFirestore? db]) : _injected = db;

  // Lazy: criar o repositório não toca no Firebase (testes não inicializam).
  FirebaseFirestore get _db => _injected ?? FirebaseFirestore.instance;

  Future<List<CatalogTrail>> fetchAll() async {
    final snap = await _db
        .collection('trails')
        .orderBy('criadoEmMs', descending: true)
        .limit(100)
        .get();
    return [for (final d in snap.docs) CatalogTrail.fromMap(d.id, d.data())];
  }

  Future<void> publish(CatalogTrail t) => _db.collection('trails').add(t.toMap());
}
