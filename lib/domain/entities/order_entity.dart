import 'package:equatable/equatable.dart';
import '../../core/constants/pricing_constants.dart';

class OrderEntity extends Equatable {
  final String id;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final ApartmentSize apartmentSize;
  final ServiceType serviceType;
  final List<ExtraService> extras;
  final int bedCount;
  final double priceMin;
  final double priceMax;
  final String status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final String? notes;
  final String? paymentProofUrl;
  final String? paymentMethod;

  const OrderEntity({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.apartmentSize,
    required this.serviceType,
    required this.extras,
    required this.bedCount,
    required this.priceMin,
    required this.priceMax,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.scheduledTime,
    this.notes,
    this.paymentProofUrl,
    this.paymentMethod,
  });

  String get priceRange => '\$${priceMin.toInt()} - \$${priceMax.toInt()}';

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isPaymentApproved => status == 'payment_approved';

  @override
  List<Object?> get props => [
        id, clientId, clientName, clientEmail, apartmentSize, serviceType,
        extras, bedCount, priceMin, priceMax, status, createdAt,
        scheduledDate, scheduledTime, notes, paymentProofUrl, paymentMethod,
      ];
}
