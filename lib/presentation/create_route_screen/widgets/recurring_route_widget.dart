import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecurringRouteWidget extends StatelessWidget {
  final bool isRecurring;
  final List<int> selectedDays;
  final Function(bool) onRecurringChanged;
  final Function(List<int>) onDaysChanged;

  const RecurringRouteWidget({
    super.key,
    required this.isRecurring,
    required this.selectedDays,
    required this.onRecurringChanged,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> weekDays = [
      {"label": "Mon", "value": 1},
      {"label": "Tue", "value": 2},
      {"label": "Wed", "value": 3},
      {"label": "Thu", "value": 4},
      {"label": "Fri", "value": 5},
      {"label": "Sat", "value": 6},
      {"label": "Sun", "value": 7},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'repeat',
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recurring Route',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Repeat this route weekly',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(value: isRecurring, onChanged: onRecurringChanged),
                ],
              ),
              if (isRecurring) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: theme.dividerColor),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: weekDays.map((day) {
                    final isSelected = selectedDays.contains(
                      day["value"] as int,
                    );
                    return InkWell(
                      onTap: () {
                        final List<int> newDays = List.from(selectedDays);
                        if (isSelected) {
                          newDays.remove(day["value"] as int);
                        } else {
                          newDays.add(day["value"] as int);
                        }
                        onDaysChanged(newDays);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            day["label"] as String,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
