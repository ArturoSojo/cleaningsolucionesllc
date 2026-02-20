import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/app_providers.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/client/client_home_screen.dart';
import '../../presentation/screens/client/quoter_screen.dart';
import '../../presentation/screens/client/my_orders_screen.dart';
import '../../presentation/screens/client/order_detail_screen.dart';
import '../../presentation/screens/client/chat_screen.dart';
import '../../presentation/screens/client/settings_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_orders_screen.dart';
import '../../presentation/screens/admin/admin_clients_screen.dart';
import '../../presentation/screens/admin/admin_expenses_screen.dart';
import '../../presentation/screens/admin/admin_chat_list_screen.dart';
import '../../presentation/screens/shared/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';

      if (isSplash) return null;
      if (!isLoggedIn && !isLogin) return '/login';
      if (isLoggedIn && isLogin) return '/client';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      // Client Routes
      ShellRoute(
        builder: (context, state, child) => ClientShell(child: child),
        routes: [
          GoRoute(
            path: '/client',
            builder: (context, state) => const ClientHomeScreen(),
          ),
          GoRoute(
            path: '/client/orders',
            builder: (context, state) => const MyOrdersScreen(),
          ),
          GoRoute(
            path: '/client/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/client/quoter',
        builder: (context, state) => const QuoterScreen(),
      ),
      GoRoute(
        path: '/client/order/:orderId',
        builder: (context, state) =>
            OrderDetailScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/client/chat/:orderId',
        builder: (context, state) =>
            ChatScreen(orderId: state.pathParameters['orderId']!),
      ),
      // Admin Routes
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/orders',
            builder: (context, state) => const AdminOrdersScreen(),
          ),
          GoRoute(
            path: '/admin/clients',
            builder: (context, state) => const AdminClientsScreen(),
          ),
          GoRoute(
            path: '/admin/expenses',
            builder: (context, state) => const AdminExpensesScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/chat',
        builder: (context, state) => const AdminChatListScreen(),
      ),
      GoRoute(
        path: '/admin/chat/:orderId',
        builder: (context, state) =>
            ChatScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/admin/order/:orderId',
        builder: (context, state) =>
            OrderDetailScreen(orderId: state.pathParameters['orderId']!),
      ),
    ],
  );
});

class ClientShell extends ConsumerStatefulWidget {
  final Widget child;
  const ClientShell({super.key, required this.child});

  @override
  ConsumerState<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends ConsumerState<ClientShell> {
  int _selectedIndex = 0;

  final _tabs = ['/client', '/client/orders', '/client/settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          context.go(_tabs[index]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _selectedIndex = 0;

  final _tabs = ['/admin', '/admin/orders', '/admin/clients', '/admin/expenses', '/admin/settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          context.go(_tabs[index]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clients'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
