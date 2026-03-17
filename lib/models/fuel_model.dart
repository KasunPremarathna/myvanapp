import 'package:cloud_firestore/cloud_firestore.dart';

class FuelModel {
  final String id;
  final String vanId;
  final String vanModel;
  final double fuelLiters;
  final double cost;
  final DateTime createdAt;

  FuelModel({
    required this.id,
    required this.vanId,
    required this.vanModel,
    required this.fuelLiters,
    required this.cost,
    required this.createdAt,
  });

  factory FuelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FuelModel(
      id: doc.id,
      vanId: data['vanId'] ?? '',
      vanModel: data['vanModel'] ?? '',
      fuelLiters: (data['fuelLiters'] as num?)?.toDouble() ?? 0.0,
      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'vanId': vanId,
        'vanModel': vanModel,
        'fuelLiters': fuelLiters,
        'cost': cost,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
