import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fuel_model.dart';
import 'auth_service.dart';

class FuelService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService;

  FuelService(this._authService);

  CollectionReference get _ref =>
      _db.collection('users').doc(_authService.userId).collection('fuelEntries');

  Stream<List<FuelModel>> getFuelEntries() {
    return _ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FuelModel.fromFirestore(d)).toList());
  }

  Future<List<FuelModel>> getFuelFiltered(DateTime start, DateTime end) async {
    final snap = await _ref
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();
    return snap.docs.map((d) => FuelModel.fromFirestore(d)).toList();
  }

  Future<void> addFuelEntry(FuelModel fuel) async {
    await _ref.add(fuel.toMap());
  }

  Future<void> deleteFuelEntry(String id) async {
    await _ref.doc(id).delete();
  }
}
