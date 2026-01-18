import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Safety & Security section widget
/// Manages emergency contacts, SOS settings, and privacy controls
class SafetySecuritySection extends StatefulWidget {
  final Map<String, dynamic> safetySettings;
  final Function(Map<String, dynamic>) onUpdate;

  const SafetySecuritySection({
    super.key,
    required this.safetySettings,
    required this.onUpdate,
  });

  @override
  State<SafetySecuritySection> createState() => _SafetySecuritySectionState();
}

class _SafetySecuritySectionState extends State<SafetySecuritySection> {
  late bool _shareLocationEnabled;
  late bool _emergencyAlertsEnabled;
  late bool _profileVisibleToAll;

  @override
  void initState() {
    super.initState();
    _shareLocationEnabled =
        widget.safetySettings['shareLocation'] as bool? ?? true;
    _emergencyAlertsEnabled =
        widget.safetySettings['emergencyAlerts'] as bool? ?? true;
    _profileVisibleToAll =
        widget.safetySettings['profileVisible'] as bool? ?? true;
  }

  void _updateSettings() {
    final updatedSettings = {
      'shareLocation': _shareLocationEnabled,
      'emergencyAlerts': _emergencyAlertsEnabled,
      'profileVisible': _profileVisibleToAll,
    };
    widget.onUpdate(updatedSettings);
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
                  iconName: 'security',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Safety & Security',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildSettingTile(
              theme: theme,
              icon: 'location_on',
              title: 'Share Location During Rides',
              subtitle: 'Allow drivers/passengers to see your location',
              value: _shareLocationEnabled,
              onChanged: (value) {
                setState(() => _shareLocationEnabled = value);
                _updateSettings();
              },
            ),
            Divider(height: 3.h),
            _buildSettingTile(
              theme: theme,
              icon: 'notifications_active',
              title: 'Emergency Alerts',
              subtitle: 'Receive notifications for safety updates',
              value: _emergencyAlertsEnabled,
              onChanged: (value) {
                setState(() => _emergencyAlertsEnabled = value);
                _updateSettings();
              },
            ),
            Divider(height: 3.h),
            _buildSettingTile(
              theme: theme,
              icon: 'visibility',
              title: 'Profile Visibility',
              subtitle: 'Make profile visible to all users',
              value: _profileVisibleToAll,
              onChanged: (value) {
                setState(() => _profileVisibleToAll = value);
                _updateSettings();
              },
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'SOS button is always available during active rides',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required ThemeData theme,
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
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
              Text(title, style: theme.textTheme.titleMedium),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
