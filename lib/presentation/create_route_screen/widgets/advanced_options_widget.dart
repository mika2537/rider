
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AdvancedOptionsWidget extends StatelessWidget {
  final bool isExpanded;
  final String genderPreference;
  final String ageRange;
  final bool smokingAllowed;
  final String specialInstructions;
  final Function(bool) onExpandChanged;
  final Function(String) onGenderChanged;
  final Function(String) onAgeRangeChanged;
  final Function(bool) onSmokingChanged;
  final Function(String) onInstructionsChanged;

  const AdvancedOptionsWidget({
    super.key,
    required this.isExpanded,
    required this.genderPreference,
    required this.ageRange,
    required this.smokingAllowed,
    required this.specialInstructions,
    required this.onExpandChanged,
    required this.onGenderChanged,
    required this.onAgeRangeChanged,
    required this.onSmokingChanged,
    required this.onInstructionsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => onExpandChanged(!isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'tune',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Advanced Options',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: theme.dividerColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passenger Preferences',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: genderPreference,
                    decoration: InputDecoration(
                      labelText: 'Gender Preference',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CustomIconWidget(
                          iconName: 'person',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                    items: ['Any', 'Male', 'Female', 'Non-binary']
                        .map(
                          (gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onGenderChanged(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: ageRange,
                    decoration: InputDecoration(
                      labelText: 'Age Range',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CustomIconWidget(
                          iconName: 'calendar_today',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                    items: ['Any', '18-25', '26-35', '36-50', '50+']
                        .map(
                          (age) =>
                          DropdownMenuItem(value: age, child: Text(age)),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onAgeRangeChanged(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'smoking_rooms',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Smoking Allowed',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      Switch(
                        value: smokingAllowed,
                        onChanged: onSmokingChanged,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Special Instructions',
                      hintText: 'Any additional information for passengers...',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 12,
                          right: 12,
                        ),
                        child: CustomIconWidget(
                          iconName: 'notes',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                    onChanged: onInstructionsChanged,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
