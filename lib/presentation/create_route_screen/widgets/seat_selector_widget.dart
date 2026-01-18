import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SeatSelectorWidget extends StatelessWidget {
  final int selectedSeats;
  final Function(int) onSeatsChanged;

  const SeatSelectorWidget({
    super.key,
    required this.selectedSeats,
    required this.onSeatsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Seats',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
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
                  Text('Number of seats', style: theme.textTheme.bodyLarge),
                  Row(
                    children: [
                      IconButton(
                        onPressed: selectedSeats > 1
                            ? () => onSeatsChanged(selectedSeats - 1)
                            : null,
                        icon: CustomIconWidget(
                          iconName: 'remove_circle_outline',
                          color: selectedSeats > 1
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            selectedSeats.toString(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: selectedSeats < 7
                            ? () => onSeatsChanged(selectedSeats + 1)
                            : null,
                        icon: CustomIconWidget(
                          iconName: 'add_circle_outline',
                          color: selectedSeats < 7
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (context, index) =>
                  const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final seatNumber = index + 1;
                    final isSelected = seatNumber == selectedSeats;
                    return InkWell(
                      onTap: () => onSeatsChanged(seatNumber),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 56,
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
                            seatNumber.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
