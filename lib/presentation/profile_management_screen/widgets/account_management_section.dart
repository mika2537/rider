import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Account Management section widget
/// Handles password change, biometric authentication, and account deletion
class AccountManagementSection extends StatefulWidget {
  final Function() onPasswordChange;
  final Function() onAccountDelete;

  const AccountManagementSection({
    super.key,
    required this.onPasswordChange,
    required this.onAccountDelete,
  });

  @override
  State<AccountManagementSection> createState() =>
      _AccountManagementSectionState();
}

class _AccountManagementSectionState extends State<AccountManagementSection> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricEnabled = false;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    if (kIsWeb) {
      setState(() => _canCheckBiometrics = false);
      return;
    }

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() => _canCheckBiometrics = canCheck && isDeviceSupported);
    } catch (e) {
      setState(() => _canCheckBiometrics = false);
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (!_canCheckBiometrics) return;

    try {
      if (value) {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Enable biometric authentication for quick login',
          biometricOnly: true,
        );

        if (authenticated) {
          setState(() => _biometricEnabled = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Biometric authentication enabled'),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        setState(() => _biometricEnabled = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Biometric authentication disabled'),
              backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to setup biometric authentication'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: theme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAccountDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'manage_accounts',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Account Management',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildActionTile(
              theme: theme,
              icon: 'lock',
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: widget.onPasswordChange,
            ),
            if (_canCheckBiometrics) ...[
              Divider(height: 3.h),
              _buildBiometricTile(theme),
            ],
            Divider(height: 3.h),
            _buildActionTile(
              theme: theme,
              icon: 'delete_forever',
              title: 'Delete Account',
              subtitle: 'Permanently remove your account',
              onTap: _showDeleteAccountDialog,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required ThemeData theme,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
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
                color: isDestructive
                    ? theme.colorScheme.error.withValues(alpha: 0.1)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: isDestructive
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDestructive ? theme.colorScheme.error : null,
                    ),
                  ),
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

  Widget _buildBiometricTile(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'fingerprint',
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Biometric Authentication',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                'Use fingerprint or face ID to login',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(value: _biometricEnabled, onChanged: _toggleBiometric),
      ],
    );
  }
}