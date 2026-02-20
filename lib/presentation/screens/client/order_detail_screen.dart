import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../data/datasources/remote/firestore_datasource.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  String _serviceName(String t) => switch (t) {
    'deep' => 'Deep Cleaning (First Time)',
    'weekly' => 'Weekly Cleaning',
    'biweekly' => 'Biweekly Cleaning',
    'monthly' => 'Monthly Cleaning',
    _ => t,
  };

  String _sizeName(String s) => switch (s) {
    'small' => 'Small (Studio / 1 bed – 1 bath)',
    'medium1' => 'Medium 1 (1 bed – 1 bath)',
    'medium2' => 'Medium 2 (2 beds – 1 bath)',
    'medium3' => 'Medium 3 (2 beds – 2 baths)',
    'large' => 'Large (3 beds – 2 baths)',
    _ => s,
  };

  Color _statusColor(String status) => switch (status) {
    'pending' => AppColors.statusPending,
    'in_progress' => AppColors.statusInProgress,
    'completed' => AppColors.statusCompleted,
    'cancelled' => AppColors.statusCancelled,
    'payment_approved' => AppColors.statusPaymentApproved,
    _ => AppColors.textSecondaryLight,
  };

  String _statusLabel(String status) => switch (status) {
    'pending' => 'Pending',
    'in_progress' => 'In Progress',
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    'payment_approved' => 'Payment Approved',
    _ => status,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderFuture = ref.watch(
      Provider((r) => r.watch(firestoreDataSourceProvider).getOrder(orderId)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: FutureBuilder(
        future: ref.read(firestoreDataSourceProvider).getOrder(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _statusColor(order.status).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: _statusColor(order.status)),
                      const SizedBox(width: 10),
                      Text(
                        'Status: ${_statusLabel(order.status)}',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: _statusColor(order.status)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Price Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      const Text('Estimated Price', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(order.priceRange, style: const TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Details
                _DetailCard(children: [
                  _DetailRow(label: 'Service', value: _serviceName(order.serviceType.name)),
                  _DetailRow(label: 'Size', value: _sizeName(order.apartmentSize.name)),
                  if (order.extras.isNotEmpty)
                    _DetailRow(label: 'Extras', value: order.extras.map((e) => e.name).join(', ')),
                  if (order.scheduledDate != null)
                    _DetailRow(label: 'Scheduled', value: '${order.scheduledDate!.day}/${order.scheduledDate!.month}/${order.scheduledDate!.year}'),
                  if (order.notes != null && order.notes!.isNotEmpty)
                    _DetailRow(label: 'Notes', value: order.notes!),
                ]),
                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/client/chat/${order.id}'),
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('Open Chat'),
                      ),
                    ),
                    if (order.status == 'pending') ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showPaymentDialog(context, ref, order.id),
                          icon: const Icon(Icons.payment_rounded),
                          label: const Text('Pay'),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Prices may vary based on home condition. Mascotas o suciedad excesiva generan ajuste.',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.navyBlue, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref, String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _PaymentBottomSheet(orderId: orderId),
    );
  }
}

class _PaymentBottomSheet extends ConsumerWidget {
  final String orderId;
  const _PaymentBottomSheet({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Instructions', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
          const SizedBox(height: 16),
          _PaymentMethodCard(method: 'Zelle', detail: 'arturosojovivas@gmail.com', icon: Icons.account_balance_wallet_rounded),
          const SizedBox(height: 10),
          _PaymentMethodCard(method: 'Venmo', detail: '@CleaningSoluciones', icon: Icons.payment_rounded),
          const SizedBox(height: 20),
          const Text('After payment, upload your screenshot to the chat for confirmation.', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondaryLight, height: 1.5)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/client/chat/$orderId');
              },
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Upload Payment Proof in Chat'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String method;
  final String detail;
  final IconData icon;
  const _PaymentMethodCard({required this.method, required this.detail, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.navyBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.navyBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(method, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
              Text(detail, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)).toList(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight))),
        Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyBlue))),
      ],
    );
  }
}
