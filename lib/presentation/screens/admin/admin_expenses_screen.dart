import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../data/models/expense_model.dart';
import '../../../domain/entities/expense_entity.dart';

class AdminExpensesScreen extends ConsumerStatefulWidget {
  const AdminExpensesScreen({super.key});
  @override
  ConsumerState<AdminExpensesScreen> createState() => _AdminExpensesScreenState();
}

class _AdminExpensesScreenState extends ConsumerState<AdminExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: expensesAsync.when(
        data: (expenses) {
          final total = expenses.fold<double>(0, (s, e) => s + e.amount);
          return Column(
            children: [
              // Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Expenses', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                          Text('\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text('${expenses.length} entries', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.white54, size: 48),
                  ],
                ),
              ),
              // Category Breakdown
              if (expenses.isNotEmpty) _CategoryBreakdown(expenses: expenses),
              // List
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondaryLight.withOpacity(0.3)),
                            const SizedBox(height: 12),
                            const Text('No expenses yet', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: expenses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _ExpenseTile(expense: expenses[i]),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _AddExpenseSheet(),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<ExpenseEntity> expenses;
  const _CategoryBreakdown({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> byCategory = {};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: byCategory.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dividerLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('\$${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
                Text(entry.key, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondaryLight)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseEntity expense;
  const _ExpenseTile({required this.expense});

  IconData _categoryIcon() => switch (expense.category.toLowerCase()) {
    'supplies' => Icons.cleaning_services_rounded,
    'transport' => Icons.directions_car_rounded,
    'salary' => Icons.people_rounded,
    'equipment' => Icons.build_rounded,
    'marketing' => Icons.campaign_rounded,
    _ => Icons.receipt_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.navyBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(_categoryIcon(), color: AppColors.navyBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyBlue),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          Text('\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
        ],
      ),
    );
  }
}

class _AddExpenseSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<_AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Supplies';
  DateTime _date = DateTime.now();
  bool _saving = false;

  final _categories = ['Supplies', 'Transport', 'Salary', 'Equipment', 'Marketing', 'Other'];

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final user = ref.read(currentUserProvider).value;
      final expense = ExpenseModel(
        id: '',
        description: _descController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        category: _category,
        date: _date,
        createdBy: user?.id ?? '',
        createdAt: DateTime.now(),
      );
      await ref.read(firestoreDataSourceProvider).addExpense(expense);
      ref.invalidate(expensesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Expense', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined)),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (\$)', prefixIcon: Icon(Icons.attach_money_rounded)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded, color: AppColors.navyBlue),
              title: Text('Date: ${_date.day}/${_date.month}/${_date.year}',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: const Text('Change'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Expense'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
