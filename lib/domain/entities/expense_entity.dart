import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final String createdBy;

  const ExpenseEntity({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [id, description, amount, category, date, notes, createdBy];
}
