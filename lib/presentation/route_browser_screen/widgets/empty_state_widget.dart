import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty state widget for route browser
class EmptyStateWidget extends StatelessWidget {
  final String type;
  final VoidCallback? onAction;

  const EmptyStateWidget({super.key, required this.type, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNoFilters = type == 'noFilters';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: isNoFilters ? 'search_off' : 'directions_car',
                  color: theme.colorScheme.primary,
                  size: 60,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              isNoFilters
                  ? 'No Routes Match Your Filters'
                  : 'No Routes Available',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              isNoFilters
                  ? 'Try adjusting your filters to see more routes in your area'
                  : 'There are no available routes in your area at the moment. Check back later!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (isNoFilters && onAction != null) ...[
              SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text('Clear Filters')),
            ],
          ],
        ),
      ),
    );
  }
}
