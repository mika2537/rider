import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickStatsCardWidget extends StatelessWidget {
  final String todayEarnings;
  final int completedRides;
  final double passengerRating;

  const QuickStatsCardWidget({
    super.key,
    required this.todayEarnings,
    required this.completedRides,
    required this.passengerRating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: 'account_balance_wallet',
              label: 'Today\'s Earnings',
              value: todayEarnings,
              color: theme.colorScheme.tertiary,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStatCard(
              context,
              icon: 'directions_car',
              label: 'Completed',
              value: completedRides.toString(),
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildStatCard(
              context,
              icon: 'star',
              label: 'Rating',
              value: passengerRating.toStringAsFixed(1),
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String icon,
        required String label,
        required String value,
        required Color color,
      }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(iconName: icon, color: color, size: 24),
          ),

          SizedBox(height: 1.h),

          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 0.5.h),

          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
