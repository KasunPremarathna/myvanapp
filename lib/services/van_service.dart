import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/van_model.dart';
import 'auth_service.dart';

class VanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService;

  VanService(this._authService);

  CollectionReference get _vansRef =>
      _db.collection('users').doc(_authService.userId).collection('vans');

  Stream<List<VanModel>> getVans() {
    return _vansRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => VanModel.fromFirestore(d)).toList());
  }

  Future<void> addVan(VanModel van) async {
    await _vansRef.add(van.toMap());
  }

  Future<void> updateVan(VanModel van) async {
    await _vansRef.doc(van.id).update(van.toMap());
  }

  Future<void> deleteVan(String vanId) async {
    await _vansRef.doc(vanId).delete();
  }
}
