import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// App Preferences section widget
/// Manages notification settings, theme mode, and language selection
class AppPreferencesSection extends StatefulWidget {
  final Map<String, dynamic> preferences;
  final Function(Map<String, dynamic>) onUpdate;

  const AppPreferencesSection({
    super.key,
    required this.preferences,
    required this.onUpdate,
  });

  @override
  State<AppPreferencesSection> createState() => _AppPreferencesSectionState();
}

class _AppPreferencesSectionState extends State<AppPreferencesSection> {
  late bool _rideRequestNotifications;
  late bool _messageNotifications;
  late bool _promotionalNotifications;
  late bool _isDarkMode;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _rideRequestNotifications =
        widget.preferences['rideRequestNotifications'] as bool? ?? true;
    _messageNotifications =
        widget.preferences['messageNotifications'] as bool? ?? true;
    _promotionalNotifications =
        widget.preferences['promotionalNotifications'] as bool? ?? false;
    _isDarkMode = widget.preferences['darkMode'] as bool? ?? false;
    _selectedLanguage = widget.preferences['language'] as String? ?? 'English';
  }

  void _updatePreferences() {
    final updatedPreferences = {
      'rideRequestNotifications': _rideRequestNotifications,
      'messageNotifications': _messageNotifications,
      'promotionalNotifications': _promotionalNotifications,
      'darkMode': _isDarkMode,
      'language': _selectedLanguage,
    };
    widget.onUpdate(updatedPreferences);
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
                  iconName: 'settings',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'App Preferences',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            _buildNotificationTile(
              theme: theme,
              icon: 'directions_car',
              title: 'Ride Requests',
              subtitle: 'Get notified about new ride requests',
              value: _rideRequestNotifications,
              onChanged: (value) {
                setState(() => _rideRequestNotifications = value);
                _updatePreferences();
              },
            ),
            _buildNotificationTile(
              theme: theme,
              icon: 'message',
              title: 'Messages',
              subtitle: 'Receive chat message notifications',
              value: _messageNotifications,
              onChanged: (value) {
                setState(() => _messageNotifications = value);
                _updatePreferences();
              },
            ),
            _buildNotificationTile(
              theme: theme,
              icon: 'campaign',
              title: 'Promotions',
              subtitle: 'Get updates about offers and deals',
              value: _promotionalNotifications,
              onChanged: (value) {
                setState(() => _promotionalNotifications = value);
                _updatePreferences();
              },
            ),
            Divider(height: 3.h),
            Text(
              'Appearance',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            _buildThemeTile(theme),
            Divider(height: 3.h),
            Text(
              'Language',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            _buildLanguageTile(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required ThemeData theme,
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
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
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildThemeTile(ThemeData theme) {
    return InkWell(
      onTap: () {
        setState(() => _isDarkMode = !_isDarkMode);
        _updatePreferences();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Theme changed to ${_isDarkMode ? 'Dark' : 'Light'} mode',
            ),
            backgroundColor: theme.colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: _isDarkMode ? 'dark_mode' : 'light_mode',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                _isDarkMode ? 'Dark Mode' : 'Light Mode',
                style: theme.textTheme.bodyLarge,
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

  Widget _buildLanguageTile(ThemeData theme) {
    return InkWell(
      onTap: () => _showLanguageDialog(theme),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'language',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(_selectedLanguage, style: theme.textTheme.bodyLarge),
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

  void _showLanguageDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German'].map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                _updatePreferences();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language changed to $value'),
                    backgroundColor: theme.colorScheme.tertiary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
