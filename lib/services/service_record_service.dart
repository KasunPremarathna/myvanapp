import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import 'auth_service.dart';

class ServiceRecordService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService;

  ServiceRecordService(this._authService);

  CollectionReference get _ref =>
      _db.collection('users').doc(_authService.userId).collection('services');

  Stream<List<ServiceModel>> getServices({String? vanId}) {
    Query query = _ref.orderBy('serviceDate', descending: true);
    if (vanId != null) {
      query = query.where('vanId', isEqualTo: vanId);
    }
    return query.snapshots().map(
        (snap) => snap.docs.map((d) => ServiceModel.fromFirestore(d)).toList());
  }

  Future<List<ServiceModel>> getServicesFiltered(
      DateTime start, DateTime end) async {
    final snap = await _ref
        .where('serviceDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('serviceDate',
            isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();
    return snap.docs.map((d) => ServiceModel.fromFirestore(d)).toList();
  }

  Future<void> addService(ServiceModel service) async {
    await _ref.add(service.toMap());
  }

  Future<void> deleteService(String serviceId) async {
    await _ref.doc(serviceId).delete();
  }
}
