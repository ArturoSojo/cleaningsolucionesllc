import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../domain/entities/user_entity.dart';

class AdminClientsScreen extends ConsumerStatefulWidget {
  const AdminClientsScreen({super.key});
  @override
  ConsumerState<AdminClientsScreen> createState() => _AdminClientsScreenState();
}

class _AdminClientsScreenState extends ConsumerState<AdminClientsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(allClientsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clients...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondaryLight),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.offWhite,
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: clientsAsync.when(
              data: (clients) {
                final filtered = _query.isEmpty
                    ? clients
                    : clients.where((c) => c.name.toLowerCase().contains(_query) || c.email.toLowerCase().contains(_query)).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textSecondaryLight.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text('No clients found', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _ClientCard(client: filtered[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final UserEntity client;
  const _ClientCard({required this.client});

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
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.navyBlue.withOpacity(0.1),
            backgroundImage: client.photoUrl != null ? NetworkImage(client.photoUrl!) : null,
            child: client.photoUrl == null
                ? Text(
                    client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyBlue),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
                Text(client.email, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondaryLight)),
                if (client.phone != null && client.phone!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text(client.phone!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: client.isAdmin ? AppColors.navyBlue.withOpacity(0.1) : AppColors.statusCompleted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  client.isAdmin ? 'Admin' : 'Client',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: client.isAdmin ? AppColors.navyBlue : AppColors.statusCompleted,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.push('/admin/client/${client.id}'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.navyBlue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
