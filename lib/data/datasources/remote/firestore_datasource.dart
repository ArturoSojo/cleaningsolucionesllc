import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../core/constants/app_constants.dart';
import '../../models/order_model.dart';
import '../../models/message_model.dart';
import '../../models/expense_model.dart';
import '../../models/user_model.dart';

class FirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirestoreDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  // ─── ORDERS ───────────────────────────────────────────────────────────────

  Future<String> createOrder(OrderModel order) async {
    final ref = _firestore.collection(AppConstants.ordersCollection).doc();
    final model = OrderModel(
      id: ref.id,
      clientId: order.clientId,
      clientName: order.clientName,
      clientEmail: order.clientEmail,
      apartmentSize: order.apartmentSize,
      serviceType: order.serviceType,
      extras: order.extras,
      bedCount: order.bedCount,
      priceMin: order.priceMin,
      priceMax: order.priceMax,
      status: order.status,
      createdAt: order.createdAt,
      scheduledDate: order.scheduledDate,
      scheduledTime: order.scheduledTime,
      notes: order.notes,
      paymentProofUrl: order.paymentProofUrl,
      paymentMethod: order.paymentMethod,
    );
    await ref.set(model.toFirestore());
    return ref.id;
  }

  Stream<List<OrderModel>> getClientOrders(String clientId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OrderModel.fromFirestore).toList());
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({'status': status});
  }

  Future<void> updateOrderPaymentProof(String orderId, String proofUrl, String method) async {
    await _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .update({'paymentProofUrl': proofUrl, 'paymentMethod': method});
  }

  // ─── MESSAGES ─────────────────────────────────────────────────────────────

  Stream<List<MessageModel>> getMessages(String orderId) {
    return _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .collection(AppConstants.messagesCollection)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(MessageModel.fromFirestore).toList());
  }

  Future<void> sendMessage(String orderId, MessageModel message) async {
    final ref = _firestore
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .collection(AppConstants.messagesCollection)
        .doc();
    await ref.set(message.toFirestore());
  }

  // ─── EXPENSES ─────────────────────────────────────────────────────────────

  Stream<List<ExpenseModel>> getExpenses() {
    return _firestore
        .collection(AppConstants.expensesCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ExpenseModel.fromFirestore).toList());
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final ref = _firestore.collection(AppConstants.expensesCollection).doc();
    await ref.set(expense.toFirestore());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore
        .collection(AppConstants.expensesCollection)
        .doc(expenseId)
        .delete();
  }

  // ─── USERS ────────────────────────────────────────────────────────────────

  Stream<List<UserModel>> getAllClients() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'client')
        .snapshots()
        .map((snap) => snap.docs.map(UserModel.fromFirestore).toList());
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ─── STORAGE ──────────────────────────────────────────────────────────────

  Future<String> uploadPaymentProof(String orderId, File file) async {
    final ref = _storage
        .ref()
        .child(AppConstants.storagePaymentProofs)
        .child(orderId)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }
}
