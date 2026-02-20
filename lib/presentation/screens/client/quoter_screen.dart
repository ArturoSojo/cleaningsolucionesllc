import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/pricing_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/order_providers.dart';
import '../../../presentation/providers/app_providers.dart';
import '../../../data/models/order_model.dart';

class QuoterScreen extends ConsumerStatefulWidget {
  const QuoterScreen({super.key});
  @override
  ConsumerState<QuoterScreen> createState() => _QuoterScreenState();
}

class _QuoterScreenState extends ConsumerState<QuoterScreen> {
  final PageController _pageController = PageController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextPage() {
    ref.read(quoterProvider.notifier).nextStep();
    _pageController.nextPage(duration: AppConstants.animNormal, curve: Curves.easeInOut);
  }

  void _prevPage() {
    final state = ref.read(quoterProvider);
    if (state.currentStep > 0) {
      ref.read(quoterProvider.notifier).previousStep();
      _pageController.previousPage(duration: AppConstants.animNormal, curve: Curves.easeInOut);
    } else {
      context.pop();
    }
  }

  Future<void> _confirmOrder() async {
    final state = ref.read(quoterProvider);
    final user = ref.read(currentUserProvider).value;
    if (user == null || !state.isComplete) return;
    final price = state.estimatedPrice!;
    final order = OrderModel(
      id: '',
      clientId: user.id,
      clientName: user.name,
      clientEmail: user.email,
      apartmentSize: state.apartmentSize!,
      serviceType: state.serviceType!,
      extras: state.extras,
      bedCount: state.bedCount,
      priceMin: price.min,
      priceMax: price.max,
      status: AppConstants.statusPending,
      createdAt: DateTime.now(),
      scheduledDate: state.preferredDate,
      scheduledTime: state.preferredTime,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    try {
      final orderId = await ref.read(firestoreDataSourceProvider).createOrder(order);
      ref.read(quoterProvider.notifier).reset();
      if (!mounted) return;
      _showSuccessDialog(orderId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Order Created!', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
            const SizedBox(height: 8),
            const Text('We will contact you shortly to confirm your appointment.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () { Navigator.pop(ctx); context.go('/client'); }, child: const Text('Home'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(ctx); context.go('/client/chat/$orderId'); }, child: const Text('View Order'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quoterProvider);
    final steps = ['Service', 'Size', 'Extras', 'Summary'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get a Quote'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: _prevPage),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: state.currentStep, steps: steps),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1ServiceType(onNext: _nextPage),
                _Step2ApartmentSize(onNext: _nextPage),
                _Step3Extras(onNext: _nextPage, notesController: _notesController),
                _Step4Summary(onConfirm: _confirmOrder),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  const _StepIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyBlue,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIndex < currentStep ? AppColors.success : Colors.white.withOpacity(0.3),
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = stepIndex == currentStep;
          final isDone = stepIndex < currentStep;
          return Column(
            children: [
              AnimatedContainer(
                duration: AppConstants.animFast,
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.success : isActive ? Colors.white : Colors.white.withOpacity(0.3),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : Text('${stepIndex + 1}', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? AppColors.navyBlue : Colors.white)),
                ),
              ),
              const SizedBox(height: 4),
              Text(steps[stepIndex], style: TextStyle(fontFamily: 'Poppins', fontSize: 9, color: isActive ? Colors.white : Colors.white.withOpacity(0.5), fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
            ],
          );
        }),
      ),
    );
  }
}

class _Step1ServiceType extends ConsumerWidget {
  final VoidCallback onNext;
  const _Step1ServiceType({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoterProvider);
    final notifier = ref.read(quoterProvider.notifier);
    final services = [
      (ServiceType.deep, 'Deep Cleaning', 'First time / thorough clean', Icons.auto_awesome_rounded, true),
      (ServiceType.weekly, 'Weekly Cleaning', 'Every week – best value!', Icons.calendar_today_rounded, false),
      (ServiceType.biweekly, 'Biweekly Cleaning', 'Every 2 weeks', Icons.event_repeat_rounded, false),
      (ServiceType.monthly, 'Monthly Cleaning', 'Once a month', Icons.date_range_rounded, false),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Service Type', style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
          const SizedBox(height: 4),
          const Text('Choose the cleaning frequency that fits your needs', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 20),
          ...services.map((s) {
            final isSelected = state.serviceType == s.$1;
            return GestureDetector(
              onTap: () => notifier.setServiceType(s.$1),
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navyBlue : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? AppColors.navyBlue : AppColors.dividerLight, width: isSelected ? 2 : 1),
                  boxShadow: [BoxShadow(color: isSelected ? AppColors.navyBlue.withOpacity(0.2) : Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.navyBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                      child: Icon(s.$4, color: isSelected ? Colors.white : AppColors.navyBlue, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(s.$2, style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.navyBlue)),
                              if (s.$5) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(6)),
                                  child: const Text('Higher Cost', style: TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ],
                            ],
                          ),
                          Text(s.$3, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: isSelected ? Colors.white.withOpacity(0.75) : AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  ],
                ),
              ),
            );
          }),
          if (state.serviceType == ServiceType.deep)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.warning.withOpacity(0.4))),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                  SizedBox(width: 10),
                  Expanded(child: Text('First-time cleaning is always deeper and has a higher cost.', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.navyBlue))),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: state.serviceType != null ? onNext : null, child: const Text('Next: Apartment Size'))),
        ],
      ),
    );
  }
}

class _Step2ApartmentSize extends ConsumerWidget {
  final VoidCallback onNext;
  const _Step2ApartmentSize({required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoterProvider);
    final notifier = ref.read(quoterProvider.notifier);
    final sizes = [
      (ApartmentSize.small, 'Small Apartment', 'Studio / 1 bed – 1 bath – living – kitchen', Icons.home_outlined),
      (ApartmentSize.medium1, 'Medium Apartment 1', '1 bed – 1 bath – living – kitchen', Icons.home_rounded),
      (ApartmentSize.medium2, 'Medium Apartment 2', '2 beds – 1 bath – living – kitchen', Icons.house_outlined),
      (ApartmentSize.medium3, 'Medium Apartment 3', '2 beds – 2 baths – living – kitchen', Icons.house_rounded),
      (ApartmentSize.large, 'Large Apartment', '3 beds – 2 baths – living – kitchen', Icons.villa_outlined),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Apartment Size', style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
          const SizedBox(height: 4),
          const Text('Choose the size that best describes your home', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 20),
          ...sizes.map((s) {
            final isSelected = state.apartmentSize == s.$1;
            final price = state.serviceType != null ? PricingConstants.apartmentPrices[s.$1]![state.serviceType!]! : null;
            return GestureDetector(
              onTap: () => notifier.setApartmentSize(s.$1),
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navyBlue : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? AppColors.navyBlue : AppColors.dividerLight, width: isSelected ? 2 : 1),
                  boxShadow: [BoxShadow(color: isSelected ? AppColors.navyBlue.withOpacity(0.2) : Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.navyBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                      child: Icon(s.$4, color: isSelected ? Colors.white : AppColors.navyBlue, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.$2, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.navyBlue)),
                          Text(s.$3, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: isSelected ? Colors.white.withOpacity(0.75) : AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                    if (price != null)
                      Text(price.formatted, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.navyBlue)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: state.apartmentSize != null ? onNext : null, child: const Text('Next: Add Extras'))),
        ],
      ),
    );
  }
}

class _Step3Extras extends ConsumerWidget {
  final VoidCallback onNext;
  final TextEditingController notesController;
  const _Step3Extras({required this.onNext, required this.notesController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoterProvider);
    final notifier = ref.read(quoterProvider.notifier);
    final extras = [
      (ExtraService.makeBeds, Icons.bed_rounded, 'Make Beds', '\$5 per bed'),
      (ExtraService.doLaundry, Icons.local_laundry_service_rounded, 'Do Laundry (1 load)', '\$20 – \$25'),
      (ExtraService.laundryFullService, Icons.dry_cleaning_rounded, 'Laundry + Dry + Fold + Beds', '\$35 – \$45'),
      (ExtraService.washDishes, Icons.soup_kitchen_rounded, 'Wash Dishes', '\$15 – \$25'),
      (ExtraService.insideOven, Icons.microwave_rounded, 'Inside Oven', '\$25 – \$35'),
      (ExtraService.insideFridge, Icons.kitchen_rounded, 'Inside Refrigerator', '\$25 – \$35'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Extra Services', style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
          const SizedBox(height: 4),
          const Text('Optional add-ons to customize your cleaning', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 20),
          ...extras.map((e) {
            final isSelected = state.extras.contains(e.$1);
            return GestureDetector(
              onTap: () => notifier.toggleExtra(e.$1),
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navyBlue.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? AppColors.navyBlue : AppColors.dividerLight, width: isSelected ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: isSelected ? AppColors.navyBlue : AppColors.navyBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                      child: Icon(e.$2, color: isSelected ? Colors.white : AppColors.navyBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.$3, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
                          Text(e.$4, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                    Checkbox(value: isSelected, onChanged: (_) => notifier.toggleExtra(e.$1), activeColor: AppColors.navyBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
            );
          }),
          if (state.extras.contains(ExtraService.makeBeds)) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.lightBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightBlue.withOpacity(0.3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Number of Beds', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(onPressed: state.bedCount > 1 ? () => notifier.setBedCount(state.bedCount - 1) : null, icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.navyBlue)),
                      Text('${state.bedCount}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
                      IconButton(onPressed: state.bedCount < 6 ? () => notifier.setBedCount(state.bedCount + 1) : null, icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.navyBlue)),
                      Text('× \$5 = \$${state.bedCount * 5}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navyBlue)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(controller: notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Special Requests / Notes (optional)', hintText: 'Any special instructions...', prefixIcon: Icon(Icons.note_alt_outlined))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onNext, child: const Text('Next: Review Summary'))),
        ],
      ),
    );
  }
}

class _Step4Summary extends ConsumerStatefulWidget {
  final VoidCallback onConfirm;
  const _Step4Summary({required this.onConfirm});
  @override
  ConsumerState<_Step4Summary> createState() => _Step4SummaryState();
}

class _Step4SummaryState extends ConsumerState<_Step4Summary> {
  bool _isLoading = false;

  String _serviceName(ServiceType t) => switch (t) {
    ServiceType.deep => 'Deep Cleaning (First Time)',
    ServiceType.weekly => 'Weekly Cleaning',
    ServiceType.biweekly => 'Biweekly Cleaning',
    ServiceType.monthly => 'Monthly Cleaning',
  };

  String _sizeName(ApartmentSize s) => switch (s) {
    ApartmentSize.small => 'Small (Studio / 1 bed – 1 bath)',
    ApartmentSize.medium1 => 'Medium 1 (1 bed – 1 bath)',
    ApartmentSize.medium2 => 'Medium 2 (2 beds – 1 bath)',
    ApartmentSize.medium3 => 'Medium 3 (2 beds – 2 baths)',
    ApartmentSize.large => 'Large (3 beds – 2 baths)',
  };

  String _extraName(ExtraService e) => switch (e) {
    ExtraService.makeBeds => 'Make Beds',
    ExtraService.doLaundry => 'Do Laundry',
    ExtraService.laundryFullService => 'Laundry Full Service',
    ExtraService.washDishes => 'Wash Dishes',
    ExtraService.insideOven => 'Inside Oven',
    ExtraService.insideFridge => 'Inside Refrigerator',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoterProvider);
    final price = state.estimatedPrice;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quote Summary', style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
          const SizedBox(height: 4),
          const Text('Review your selection before confirming', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 20),
          // Price Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const Text('Estimated Price', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(price?.formatted ?? '--', style: const TextStyle(fontFamily: 'Poppins', fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Final price confirmed after inspection', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white60)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.dividerLight)),
            child: Column(
              children: [
                _SummaryRow(label: 'Service Type', value: state.serviceType != null ? _serviceName(state.serviceType!) : '--'),
                const Divider(height: 20),
                _SummaryRow(label: 'Apartment Size', value: state.apartmentSize != null ? _sizeName(state.apartmentSize!) : '--'),
                if (state.extras.isNotEmpty) ...[
                  const Divider(height: 20),
                  _SummaryRow(label: 'Extras', value: state.extras.map(_extraName).join(', ')),
                ],
                if (state.extras.contains(ExtraService.makeBeds)) ...[
                  const Divider(height: 20),
                  _SummaryRow(label: 'Beds', value: '${state.bedCount} bed(s)'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.warning.withOpacity(0.3))),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
                SizedBox(width: 10),
                Expanded(child: Text('Prices may vary based on home condition. Mascotas o suciedad excesiva generan ajuste.', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: AppColors.navyBlue, height: 1.5))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                await widget.onConfirm();
                if (mounted) setState(() => _isLoading = false);
              },
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.textSecondaryLight))),
        Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyBlue))),
      ],
    );
  }
}
