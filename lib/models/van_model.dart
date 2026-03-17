import 'package:cloud_firestore/cloud_firestore.dart';

class VanModel {
  final String id;
  final String vanNumber;
  final String vanModel;
  final String vanYear;
  final String vanCategory;
  final DateTime createdAt;

  VanModel({
    required this.id,
    required this.vanNumber,
    required this.vanModel,
    required this.vanYear,
    required this.vanCategory,
    required this.createdAt,
  });

  factory VanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VanModel(
      id: doc.id,
      vanNumber: data['vanNumber'] ?? '',
      vanModel: data['vanModel'] ?? '',
      vanYear: data['vanYear'] ?? '',
      vanCategory: data['vanCategory'] ?? 'Petrol',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toMap() => {
        'vanNumber': vanNumber,
        'vanModel': vanModel,
        'vanYear': vanYear,
        'vanCategory': vanCategory,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VanModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
