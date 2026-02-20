import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../presentation/providers/app_providers.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final localePref = ref.watch(localePrefProvider);
    final themePref = ref.watch(themePrefProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Admin Profile Card
          userAsync.when(
            data: (user) => user == null
                ? const SizedBox()
                : Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                          child: user.photoUrl == null ? const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 32) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                              Text(user.email, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white.withOpacity(0.8))),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                child: const Text('ADMINISTRATOR', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: _localeName(localePref),
            onTap: () => _showLanguagePicker(context, ref, localePref),
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _themeName(themePref),
            onTap: () => _showThemePicker(context, ref, themePref),
          ),
          const SizedBox(height: 16),

          _SectionHeader(title: 'Business'),
          _SettingsTile(
            icon: Icons.business_rounded,
            title: 'Company',
            subtitle: AppConstants.appName,
            onTap: null,
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: AppConstants.appVersion,
            onTap: null,
          ),
          const SizedBox(height: 16),

          _SectionHeader(title: 'Account'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
              onTap: () => _confirmSignOut(context, ref),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _localeName(String code) => switch (code) {
    'en' => 'English',
    'es' => 'Español',
    'fr' => 'Français',
    _ => 'System Default',
  };

  String _themeName(String code) => switch (code) {
    'light' => 'Light Mode',
    'dark' => 'Dark Mode',
    _ => 'System Default',
  };

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Language', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
            const SizedBox(height: 16),
            ...[('system', 'System Default', '🌐'), ('en', 'English', '🇺🇸'), ('es', 'Español', '🇪🇸'), ('fr', 'Français', '🇫🇷')].map(
              (lang) => ListTile(
                leading: Text(lang.$3, style: const TextStyle(fontSize: 24)),
                title: Text(lang.$2, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: current == lang.$1 ? const Icon(Icons.check_rounded, color: AppColors.navyBlue) : null,
                onTap: () {
                  ref.read(localePrefProvider.notifier).state = lang.$1;
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Theme', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyBlue)),
            const SizedBox(height: 16),
            ...[('system', 'System Default', Icons.brightness_auto_rounded), ('light', 'Light Mode', Icons.light_mode_rounded), ('dark', 'Dark Mode', Icons.dark_mode_rounded)].map(
              (theme) => ListTile(
                leading: Icon(theme.$3, color: AppColors.navyBlue),
                title: Text(theme.$2, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: current == theme.$1 ? const Icon(Icons.check_rounded, color: AppColors.navyBlue) : null,
                onTap: () {
                  ref.read(themePrefProvider.notifier).state = theme.$1;
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight, letterSpacing: 0.5)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.navyBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.navyBlue, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.navyBlue)),
        subtitle: Text(subtitle, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: AppColors.textSecondaryLight)),
        trailing: onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight) : null,
        onTap: onTap,
      ),
    );
  }
}
