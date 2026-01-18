import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/account_management_section.dart';
import './widgets/app_preferences_section.dart';
import './widgets/personal_info_section.dart';
import './widgets/profile_header_widget.dart';
import './widgets/safety_security_section.dart';
import './widgets/vehicle_info_section.dart';

/// Profile Management Screen
/// Provides comprehensive user account configuration, safety settings, and app preferences
/// Accessible via 'Profile' tab in bottom navigation
class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  late Map<String, dynamic> _userData;
  late Map<String, dynamic> _vehicleData;
  late Map<String, dynamic> _safetySettings;
  late Map<String, dynamic> _appPreferences;
  final bool _isDriver = true;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    _userData = {
      'name': 'Michael Rodriguez',
      'phone': '+1 (555) 123-4567',
      'email': 'michael.rodriguez@email.com',
      'emergencyContact': '+1 (555) 987-6543',
      'photoUrl':
      'https://img.rocket.new/generatedImages/rocket_gen_img_1b77f1a1e-1767195153197.png',
      'rating': 4.8,
      'phoneVerified': true,
      'emailVerified': true,
      'idVerified': true,
    };

    _vehicleData = {
      'carModel': 'Toyota Camry 2022',
      'licensePlate': 'ABC-1234',
      'color': 'Silver',
      'insuranceDocument': 'insurance_2024.pdf',
    };

    _safetySettings = {
      'shareLocation': true,
      'emergencyAlerts': true,
      'profileVisible': true,
    };

    _appPreferences = {
      'rideRequestNotifications': true,
      'messageNotifications': true,
      'promotionalNotifications': false,
      'darkMode': false,
      'language': 'English',
    };
  }

  void _updateUserData(Map<String, dynamic> updatedData) {
    setState(() {
      _userData.addAll(updatedData);
    });
  }

  void _updateVehicleData(Map<String, dynamic> updatedData) {
    setState(() {
      _vehicleData.addAll(updatedData);
    });
  }

  void _updateSafetySettings(Map<String, dynamic> updatedSettings) {
    setState(() {
      _safetySettings.addAll(updatedSettings);
    });
  }

  void _updateAppPreferences(Map<String, dynamic> updatedPreferences) {
    setState(() {
      _appPreferences.addAll(updatedPreferences);
    });
  }

  void _handlePhotoChange(String photoPath) {
    setState(() {
      _userData['photoUrl'] = photoPath;
    });
  }

  void _handlePasswordChange() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password changed successfully'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _handleAccountDelete() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Account deletion initiated. You will be logged out.',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil('/splash-screen', (route) => false);
      }
    });
  }

  void _navigateToWallet() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Wallet feature coming soon'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Help & Support feature coming soon'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeaderWidget(
              userData: _userData,
              onPhotoChanged: _handlePhotoChange,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                children: [
                  PersonalInfoSection(
                    userData: _userData,
                    onSave: _updateUserData,
                  ),
                  if (_isDriver)
                    VehicleInfoSection(
                      vehicleData: _vehicleData,
                      onUpdate: _updateVehicleData,
                    ),
                  SafetySecuritySection(
                    safetySettings: _safetySettings,
                    onUpdate: _updateSafetySettings,
                  ),
                  AppPreferencesSection(
                    preferences: _appPreferences,
                    onUpdate: _updateAppPreferences,
                  ),
                  _buildQuickActionsSection(theme),
                  AccountManagementSection(
                    onPasswordChange: _handlePasswordChange,
                    onAccountDelete: _handleAccountDelete,
                  ),
                  _buildFooterSection(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildQuickActionTile(
              theme: theme,
              icon: 'account_balance_wallet',
              title: 'Payment & Billing',
              subtitle: 'Manage wallet and payment methods',
              onTap: _navigateToWallet,
            ),
            Divider(height: 3.h),
            _buildQuickActionTile(
              theme: theme,
              icon: 'help_outline',
              title: 'Help & Support',
              subtitle: 'FAQs, contact support, feedback',
              onTap: _navigateToHelp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required ThemeData theme,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Terms of Service'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Terms'),
              ),
              Text(
                '•',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Privacy Policy'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Privacy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
