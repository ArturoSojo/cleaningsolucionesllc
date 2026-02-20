import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../domain/entities/order_entity.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrdersAsync = ref.watch(allOrdersProvider);
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('CLEANING SOLUCIONES LLC', style: TextStyle(fontSize: 10, color: AppColors.skyBlue, letterSpacing: 0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allOrdersProvider);
          ref.invalidate(expensesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats Row
            allOrdersAsync.when(
              data: (orders) {
                final pending = orders.where((o) => o.status == 'pending').length;
                final inProgress = orders.where((o) => o.status == 'in_progress').length;
                final completed = orders.where((o) => o.status == 'completed').length;
                final total = orders.length;
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'Total Orders', value: '$total', icon: Icons.receipt_long_rounded, color: AppColors.navyBlue)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(label: 'Pending', value: '$pending', icon: Icons.hourglass_empty_rounded, color: AppColors.statusPending)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'In Progress', value: '$inProgress', icon: Icons.cleaning_services_rounded, color: AppColors.statusInProgress)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(label: 'Completed', value: '$completed', icon: Icons.check_circle_outline_rounded, color: AppColors.statusCompleted)),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(height: 140, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 20),

            // Revenue Card
            expensesAsync.when(
              data: (expenses) {
                final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Expenses', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                            Text('\$${totalExpenses.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.trending_down_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => const SizedBox(),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            const Text('Quick Actions', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _QuickAction(icon: Icons.view_kanban_rounded, label: 'Orders', onTap: () => context.go('/admin/orders')),
                _QuickAction(icon: Icons.people_alt_rounded, label: 'Clients', onTap: () => context.go('/admin/clients')),
                _QuickAction(icon: Icons.receipt_rounded, label: 'Expenses', onTap: () => context.go('/admin/expenses')),
                _QuickAction(icon: Icons.chat_rounded, label: 'Chats', onTap: () => context.go('/admin/chat')),
                _QuickAction(icon: Icons.bar_chart_rounded, label: 'Reports', onTap: () {}),
                _QuickAction(icon: Icons.settings_rounded, label: 'Settings', onTap: () => context.go('/admin/settings')),
              ],
            ),
            const SizedBox(height: 20),

            // Recent Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Orders', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
                TextButton(onPressed: () => context.go('/admin/orders'), child: const Text('See All')),
              ],
            ),
            const SizedBox(height: 8),
            allOrdersAsync.when(
              data: (orders) {
                final recent = orders.take(5).toList();
                if (recent.isEmpty) return const Center(child: Text('No orders yet'));
                return Column(
                  children: recent.map((o) => _RecentOrderTile(order: o)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondaryLight)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.navyBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.navyBlue, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final OrderEntity order;
  const _RecentOrderTile({required this.order});

  Color _statusColor() => switch (order.status) {
    'pending' => AppColors.statusPending,
    'in_progress' => AppColors.statusInProgress,
    'completed' => AppColors.statusCompleted,
    'cancelled' => AppColors.statusCancelled,
    _ => AppColors.textSecondaryLight,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _statusColor(), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.clientName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
                Text(order.serviceType.name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          Text(order.priceRange, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight, size: 18),
        ],
      ),
    );
  }
}
