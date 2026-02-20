import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../domain/entities/order_entity.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Not logged in'));
          final ordersAsync = ref.watch(clientOrdersProvider(user.id));
          return ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.textSecondaryLight.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      const Text('No orders yet', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
                      const SizedBox(height: 8),
                      const Text('Book your first cleaning service!', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/client/quoter'),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Book Now'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _OrderCard(order: orders[i]),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/client/quoter'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Booking'),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  const _OrderCard({required this.order});

  Color _statusColor() {
    switch (order.status) {
      case 'pending': return AppColors.statusPending;
      case 'in_progress': return AppColors.statusInProgress;
      case 'completed': return AppColors.statusCompleted;
      case 'cancelled': return AppColors.statusCancelled;
      case 'payment_approved': return AppColors.statusPaymentApproved;
      default: return AppColors.textSecondaryLight;
    }
  }

  String _statusLabel() {
    switch (order.status) {
      case 'pending': return 'Pending';
      case 'in_progress': return 'In Progress';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'payment_approved': return 'Payment Approved';
      default: return order.status;
    }
  }

  String _serviceName() {
    switch (order.serviceType.name) {
      case 'deep': return 'Deep Cleaning';
      case 'weekly': return 'Weekly';
      case 'biweekly': return 'Biweekly';
      case 'monthly': return 'Monthly';
      default: return order.serviceType.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/client/order/${order.id}'),
      child: Container(
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.navyBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.cleaning_services_rounded, color: AppColors.navyBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_serviceName(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
                      Text(timeago.format(order.createdAt), style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor().withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(_statusLabel(), style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor())),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.home_outlined, size: 14, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(order.apartmentSize.name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondaryLight)),
                const Spacer(),
                Text(order.priceRange, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/client/chat/${order.id}'),
                    icon: const Icon(Icons.chat_outlined, size: 16),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/client/order/${order.id}'),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
