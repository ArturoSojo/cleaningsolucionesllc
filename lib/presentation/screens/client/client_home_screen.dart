import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../core/constants/app_constants.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.navyBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.brandGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            userAsync.when(
                              data: (user) => CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage: user?.photoUrl != null
                                    ? NetworkImage(user!.photoUrl!)
                                    : null,
                                child: user?.photoUrl == null
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                              loading: () => const CircleAvatar(radius: 22, backgroundColor: Colors.white24),
                              error: (_, __) => const CircleAvatar(radius: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: userAsync.when(
                                data: (user) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello, ${user?.name.split(' ').first ?? 'there'}!',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'What can we clean for you today?',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: AppColors.skyBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                loading: () => const SizedBox(),
                                error: (_, __) => const SizedBox(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Book Now CTA
                        GestureDetector(
                          onTap: () => context.push('/client/quoter'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.navyBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.cleaning_services_rounded,
                                      color: AppColors.navyBlue, size: 22),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Book a Cleaning',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.navyBlue,
                                        ),
                                      ),
                                      Text(
                                        'Get an instant quote',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    color: AppColors.navyBlue, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  _StatsRow(ref: ref),
                  const SizedBox(height: 28),

                  // Our Services
                  const Text(
                    'Our Services',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Professional cleaning solutions for every need',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Service Cards Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85,
                    children: [
                      _ServiceCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Deep Cleaning',
                        subtitle: 'First time / thorough',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3A6B), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        priceFrom: '\$110',
                        onTap: () => context.push('/client/quoter'),
                        isHighlighted: true,
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                      _ServiceCard(
                        icon: Icons.calendar_today_rounded,
                        title: 'Weekly',
                        subtitle: 'Every week',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        priceFrom: '\$80',
                        onTap: () => context.push('/client/quoter'),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      _ServiceCard(
                        icon: Icons.event_repeat_rounded,
                        title: 'Biweekly',
                        subtitle: 'Every 2 weeks',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        priceFrom: '\$95',
                        onTap: () => context.push('/client/quoter'),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      _ServiceCard(
                        icon: Icons.date_range_rounded,
                        title: 'Monthly',
                        subtitle: 'Once a month',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        priceFrom: '\$110',
                        onTap: () => context.push('/client/quoter'),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Extras Section
                  const Text(
                    'Add-On Services',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ExtrasRow(),

                  const SizedBox(height: 28),

                  // Why Choose Us
                  _WhyChooseUsCard(),

                  const SizedBox(height: 28),

                  // Price Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.warning, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Prices may vary based on home condition. Homes with pets or excessive dirt may incur an adjustment. Special discount for weekly clients!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.navyBlue,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final WidgetRef ref;
  const _StatsRow({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox();
        final ordersAsync = ref.watch(clientOrdersProvider(user.id));
        return ordersAsync.when(
          data: (orders) {
            final completed = orders.where((o) => o.isCompleted).length;
            final pending = orders.where((o) => o.isPending).length;
            return Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: orders.length.toString(),
                    label: 'Total Orders',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.navyBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: completed.toString(),
                    label: 'Completed',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: pending.toString(),
                    label: 'Pending',
                    icon: Icons.pending_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox(),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final String priceFrom;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.priceFrom,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isHighlighted)
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'From $priceFrom',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtrasRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final extras = [
      {'icon': Icons.bed_rounded, 'label': 'Make Beds', 'price': '\$5/bed'},
      {'icon': Icons.local_laundry_service_rounded, 'label': 'Laundry', 'price': '\$20-25'},
      {'icon': Icons.kitchen_rounded, 'label': 'Inside Fridge', 'price': '\$25-35'},
      {'icon': Icons.microwave_rounded, 'label': 'Inside Oven', 'price': '\$25-35'},
      {'icon': Icons.soup_kitchen_rounded, 'label': 'Wash Dishes', 'price': '\$15-25'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: extras.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final extra = extras[i];
          return Container(
            width: 90,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dividerLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(extra['icon'] as IconData, color: AppColors.navyBlue, size: 24),
                const SizedBox(height: 6),
                Text(
                  extra['label'] as String,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navyBlue,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  extra['price'] as String,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WhyChooseUsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.lightGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Choose Us?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.navyBlue,
            ),
          ),
          const SizedBox(height: 14),
          ...[
            ('✓', 'Professional & trusted team'),
            ('✓', 'Eco-friendly cleaning products'),
            ('✓', 'Flexible scheduling'),
            ('✓', 'Satisfaction guaranteed'),
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyBlue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.navyBlue,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
