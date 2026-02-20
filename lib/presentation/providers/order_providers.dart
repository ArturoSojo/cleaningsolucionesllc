import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/pricing_constants.dart';
import '../../data/datasources/remote/firestore_datasource.dart';
import '../../data/models/order_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/expense_model.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/expense_entity.dart';
import 'app_providers.dart';

// ─── ORDERS ───────────────────────────────────────────────────────────────────

final clientOrdersProvider = StreamProvider.family<List<OrderEntity>, String>((ref, clientId) {
  return ref.watch(firestoreDataSourceProvider).getClientOrders(clientId);
});

final allOrdersProvider = StreamProvider<List<OrderEntity>>((ref) {
  return ref.watch(firestoreDataSourceProvider).getAllOrders();
});

// ─── MESSAGES ─────────────────────────────────────────────────────────────────

final messagesProvider = StreamProvider.family<List<MessageEntity>, String>((ref, orderId) {
  return ref.watch(firestoreDataSourceProvider).getMessages(orderId);
});

// ─── EXPENSES ─────────────────────────────────────────────────────────────────

final expensesProvider = StreamProvider<List<ExpenseEntity>>((ref) {
  return ref.watch(firestoreDataSourceProvider).getExpenses();
});

// ─── CLIENTS ──────────────────────────────────────────────────────────────────

final allClientsProvider = StreamProvider((ref) {
  return ref.watch(firestoreDataSourceProvider).getAllClients();
});

// ─── QUOTER STATE ─────────────────────────────────────────────────────────────

class QuoterState {
  final int currentStep;
  final ServiceType? serviceType;
  final ApartmentSize? apartmentSize;
  final List<ExtraService> extras;
  final int bedCount;
  final DateTime? preferredDate;
  final String? preferredTime;
  final String? notes;

  const QuoterState({
    this.currentStep = 0,
    this.serviceType,
    this.apartmentSize,
    this.extras = const [],
    this.bedCount = 1,
    this.preferredDate,
    this.preferredTime,
    this.notes,
  });

  QuoterState copyWith({
    int? currentStep,
    ServiceType? serviceType,
    ApartmentSize? apartmentSize,
    List<ExtraService>? extras,
    int? bedCount,
    DateTime? preferredDate,
    String? preferredTime,
    String? notes,
  }) {
    return QuoterState(
      currentStep: currentStep ?? this.currentStep,
      serviceType: serviceType ?? this.serviceType,
      apartmentSize: apartmentSize ?? this.apartmentSize,
      extras: extras ?? this.extras,
      bedCount: bedCount ?? this.bedCount,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      notes: notes ?? this.notes,
    );
  }

  PriceRange? get estimatedPrice {
    if (serviceType == null || apartmentSize == null) return null;
    return PricingConstants.calculateTotal(
      size: apartmentSize!,
      service: serviceType!,
      extras: extras,
      bedCount: bedCount,
    );
  }

  bool get isComplete =>
      serviceType != null && apartmentSize != null;
}

class QuoterNotifier extends StateNotifier<QuoterState> {
  QuoterNotifier() : super(const QuoterState());

  void setServiceType(ServiceType type) {
    state = state.copyWith(serviceType: type);
  }

  void setApartmentSize(ApartmentSize size) {
    state = state.copyWith(apartmentSize: size);
  }

  void toggleExtra(ExtraService extra) {
    final current = List<ExtraService>.from(state.extras);
    if (current.contains(extra)) {
      current.remove(extra);
    } else {
      current.add(extra);
    }
    state = state.copyWith(extras: current);
  }

  void setBedCount(int count) {
    state = state.copyWith(bedCount: count);
  }

  void setPreferredDate(DateTime date) {
    state = state.copyWith(preferredDate: date);
  }

  void setPreferredTime(String time) {
    state = state.copyWith(preferredTime: time);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void reset() {
    state = const QuoterState();
  }
}

final quoterProvider = StateNotifierProvider<QuoterNotifier, QuoterState>((ref) {
  return QuoterNotifier();
});

// ─── ORDER ACTIONS ────────────────────────────────────────────────────────────

final createOrderProvider = Provider<Future<String> Function(OrderModel)>((ref) {
  return (order) => ref.read(firestoreDataSourceProvider).createOrder(order);
});

final updateOrderStatusProvider = Provider<Future<void> Function(String, String)>((ref) {
  return (orderId, status) =>
      ref.read(firestoreDataSourceProvider).updateOrderStatus(orderId, status);
});

final sendMessageProvider = Provider<Future<void> Function(String, MessageModel)>((ref) {
  return (orderId, message) =>
      ref.read(firestoreDataSourceProvider).sendMessage(orderId, message);
});

final addExpenseProvider = Provider<Future<void> Function(ExpenseModel)>((ref) {
  return (expense) => ref.read(firestoreDataSourceProvider).addExpense(expense);
});

final uploadPaymentProofProvider =
    Provider<Future<String> Function(String, dynamic)>((ref) {
  return (orderId, file) =>
      ref.read(firestoreDataSourceProvider).uploadPaymentProof(orderId, file);
});
