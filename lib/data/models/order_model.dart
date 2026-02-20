import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/pricing_constants.dart';
import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.clientId,
    required super.clientName,
    required super.clientEmail,
    required super.apartmentSize,
    required super.serviceType,
    required super.extras,
    required super.bedCount,
    required super.priceMin,
    required super.priceMax,
    required super.status,
    required super.createdAt,
    super.scheduledDate,
    super.scheduledTime,
    super.notes,
    super.paymentProofUrl,
    super.paymentMethod,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      apartmentSize: ApartmentSize.values.firstWhere(
        (e) => e.name == data['apartmentSize'],
        orElse: () => ApartmentSize.small,
      ),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == data['serviceType'],
        orElse: () => ServiceType.deep,
      ),
      extras: (data['extras'] as List<dynamic>? ?? [])
          .map((e) => ExtraService.values.firstWhere(
                (es) => es.name == e,
                orElse: () => ExtraService.makeBeds,
              ))
          .toList(),
      bedCount: data['bedCount'] ?? 1,
      priceMin: (data['priceMin'] ?? 0).toDouble(),
      priceMax: (data['priceMax'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scheduledDate: (data['scheduledDate'] as Timestamp?)?.toDate(),
      scheduledTime: data['scheduledTime'],
      notes: data['notes'],
      paymentProofUrl: data['paymentProofUrl'],
      paymentMethod: data['paymentMethod'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'apartmentSize': apartmentSize.name,
      'serviceType': serviceType.name,
      'extras': extras.map((e) => e.name).toList(),
      'bedCount': bedCount,
      'priceMin': priceMin,
      'priceMax': priceMax,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledDate': scheduledDate != null ? Timestamp.fromDate(scheduledDate!) : null,
      'scheduledTime': scheduledTime,
      'notes': notes,
      'paymentProofUrl': paymentProofUrl,
      'paymentMethod': paymentMethod,
    };
  }

  OrderModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientEmail,
    ApartmentSize? apartmentSize,
    ServiceType? serviceType,
    List<ExtraService>? extras,
    int? bedCount,
    double? priceMin,
    double? priceMax,
    String? status,
    DateTime? createdAt,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? notes,
    String? paymentProofUrl,
    String? paymentMethod,
  }) {
    return OrderModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      apartmentSize: apartmentSize ?? this.apartmentSize,
      serviceType: serviceType ?? this.serviceType,
      extras: extras ?? this.extras,
      bedCount: bedCount ?? this.bedCount,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      notes: notes ?? this.notes,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
