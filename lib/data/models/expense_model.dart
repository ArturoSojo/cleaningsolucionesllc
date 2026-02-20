import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    required super.description,
    required super.amount,
    required super.category,
    required super.date,
    super.notes,
    required super.createdBy,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? 'other',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdBy': createdBy,
    };
  }
}
