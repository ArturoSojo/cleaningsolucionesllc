import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../data/datasources/remote/firestore_datasource.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['all', 'pending', 'in_progress', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _tabLabel(String s) => switch (s) {
    'all' => 'All',
    'pending' => 'Pending',
    'in_progress' => 'Active',
    'completed' => 'Done',
    'cancelled' => 'Cancelled',
    _ => s,
  };

  @override
  Widget build(BuildContext context) {
    final allOrdersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _statuses.map((s) => Tab(text: _tabLabel(s))).toList(),
        ),
      ),
      body: allOrdersAsync.when(
        data: (orders) => TabBarView(
          controller: _tabController,
          children: _statuses.map((status) {
            final filtered = status == 'all'
                ? orders
                : orders.where((o) => o.status == status).toList();
            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded, size: 64, color: AppColors.textSecondaryLight.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No ${_tabLabel(status).toLowerCase()} orders',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.textSecondaryLight)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _AdminOrderCard(order: filtered[i]),
            );
          }).toList(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AdminOrderCard extends ConsumerWidget {
  final OrderEntity order;
  const _AdminOrderCard({required this.order});

  Color _statusColor() => switch (order.status) {
    'pending' => AppColors.statusPending,
    'in_progress' => AppColors.statusInProgress,
    'completed' => AppColors.statusCompleted,
    'cancelled' => AppColors.statusCancelled,
    'payment_approved' => AppColors.statusPaymentApproved,
    _ => AppColors.textSecondaryLight,
  };

  String _statusLabel() => switch (order.status) {
    'pending' => 'Pending',
    'in_progress' => 'In Progress',
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    'payment_approved' => 'Payment Approved',
    _ => order.status,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.clientName,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
                    Text(order.clientEmail,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel(),
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor())),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.cleaning_services_rounded, size: 14, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(order.serviceType.name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondaryLight)),
              const SizedBox(width: 12),
              const Icon(Icons.home_outlined, size: 14, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(order.apartmentSize.name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondaryLight)),
              const Spacer(),
              Text(order.priceRange,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
            ],
          ),
          const SizedBox(height: 12),
          // Status Update Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusButton(label: 'Pending', status: 'pending', current: order.status, orderId: order.id, ref: ref),
                const SizedBox(width: 6),
                _StatusButton(label: 'In Progress', status: 'in_progress', current: order.status, orderId: order.id, ref: ref),
                const SizedBox(width: 6),
                _StatusButton(label: 'Completed', status: 'completed', current: order.status, orderId: order.id, ref: ref),
                const SizedBox(width: 6),
                _StatusButton(label: 'Cancelled', status: 'cancelled', current: order.status, orderId: order.id, ref: ref),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/admin/chat/${order.id}'),
                  icon: const Icon(Icons.chat_outlined, size: 16),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/admin/order/${order.id}'),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Manage'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final String status;
  final String current;
  final String orderId;
  final WidgetRef ref;
  const _StatusButton({
    required this.label,
    required this.status,
    required this.current,
    required this.orderId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == status;
    return GestureDetector(
      onTap: isActive
          ? null
          : () async {
              await ref.read(firestoreDataSourceProvider).updateOrderStatus(orderId, status);
              ref.invalidate(allOrdersProvider);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColors.navyBlue : AppColors.offWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.navyBlue : AppColors.dividerLight),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
