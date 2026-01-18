import 'package:flutter/material.dart';

/// Custom bottom navigation bar for the ride-sharing application.
/// Implements role-adaptive navigation with thumb-accessible primary actions.
///
/// This widget is parameterized and reusable across different implementations.
/// Navigation logic is NOT hardcoded - it uses callbacks for flexibility.
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when a navigation item is tapped
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
      selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
      unselectedLabelStyle: theme.bottomNavigationBarTheme.unselectedLabelStyle,
      elevation: 8.0,
      items: [
        // Home/Dashboard - Role-specific control center
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined, size: 24),
          activeIcon: const Icon(Icons.home, size: 24),
          label: 'Home',
          tooltip: 'Dashboard and active ride status',
        ),

        // Browse/Routes - Route discovery and management
        BottomNavigationBarItem(
          icon: const Icon(Icons.explore_outlined, size: 24),
          activeIcon: const Icon(Icons.explore, size: 24),
          label: 'Routes',
          tooltip: 'Browse and manage routes',
        ),

        // Activity/Requests - Ride history and passenger requests
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined, size: 24),
          activeIcon: const Icon(Icons.receipt_long, size: 24),
          label: 'Activity',
          tooltip: 'Ride history and requests',
        ),

        // Wallet/Earnings - Payment management
        BottomNavigationBarItem(
          icon: const Icon(Icons.account_balance_wallet_outlined, size: 24),
          activeIcon: const Icon(Icons.account_balance_wallet, size: 24),
          label: 'Wallet',
          tooltip: 'Payment and earnings',
        ),

        // Profile - Account and safety settings
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline, size: 24),
          activeIcon: const Icon(Icons.person, size: 24),
          label: 'Profile',
          tooltip: 'Account settings and safety',
        ),
      ],
    );
  }
}
