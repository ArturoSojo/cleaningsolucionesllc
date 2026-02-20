import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../domain/entities/order_entity.dart';

class AdminChatListScreen extends ConsumerWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrdersAsync = ref.watch(allOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Client Chats')),
      body: allOrdersAsync.when(
        data: (orders) {
          final active = orders.where((o) => o.status != 'cancelled').toList();
          if (active.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textSecondaryLight.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  const Text('No active chats', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.textSecondaryLight)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: active.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _ChatListTile(order: active[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final OrderEntity order;
  const _ChatListTile({required this.order});

  Color _statusColor() => switch (order.status) {
    'pending' => AppColors.statusPending,
    'in_progress' => AppColors.statusInProgress,
    'completed' => AppColors.statusCompleted,
    _ => AppColors.textSecondaryLight,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/admin/chat/${order.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dividerLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.navyBlue.withOpacity(0.1),
              child: Text(
                order.clientName.isNotEmpty ? order.clientName[0].toUpperCase() : '?',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyBlue),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.clientName,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
                  Text('${order.serviceType.name} • ${order.apartmentSize.name}',
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: _statusColor(), shape: BoxShape.circle),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
