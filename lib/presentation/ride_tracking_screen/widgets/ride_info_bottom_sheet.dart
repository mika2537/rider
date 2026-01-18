import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Bottom sheet widget displaying ride information and controls
class RideInfoBottomSheet extends StatelessWidget {
  final Map<String, dynamic> rideData;
  final bool isDriver;
  final VoidCallback onEmergency;
  final VoidCallback? onMarkPickedUp;
  final VoidCallback? onCompleteRide;
  final VoidCallback? onShareLocation;
  final VoidCallback? onReportIssue;

  const RideInfoBottomSheet({
    super.key,
    required this.rideData,
    required this.isDriver,
    required this.onEmergency,
    this.onMarkPickedUp,
    this.onCompleteRide,
    this.onShareLocation,
    this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                _buildStatusIndicator(theme),

                SizedBox(height: 2.h),

                // User information
                _buildUserInfo(theme),

                SizedBox(height: 2.h),

                // Ride details
                _buildRideDetails(theme),

                SizedBox(height: 2.h),

                // Action buttons
                if (isDriver)
                  _buildDriverActions(theme)
                else
                  _buildPassengerActions(theme),

                SizedBox(height: 1.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    final status = rideData['status'] as String;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'En Route to Pickup':
        statusColor = theme.colorScheme.tertiary;
        statusIcon = Icons.directions_car;
        break;
      case 'Passenger Aboard':
        statusColor = AppTheme.successLight;
        statusIcon = Icons.check_circle;
        break;
      case 'Approaching Destination':
        statusColor = AppTheme.warningLight;
        statusIcon = Icons.location_on;
        break;
      default:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.info;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: statusIcon.codePoint.toRadixString(16),
            color: statusColor,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              status,
              style: theme.textTheme.titleMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    final userName = isDriver
        ? (rideData['passengerName'] as String)
        : (rideData['driverName'] as String);
    final userImage = isDriver
        ? (rideData['passengerImage'] as String)
        : (rideData['driverImage'] as String);
    final userRating = isDriver
        ? (rideData['passengerRating'] as double)
        : (rideData['driverRating'] as double);
    final userSemanticLabel = isDriver
        ? (rideData['passengerSemanticLabel'] as String)
        : (rideData['driverSemanticLabel'] as String);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: CustomImageWidget(
            imageUrl: userImage,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            semanticLabel: userSemanticLabel,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDriver ? 'Passenger' : 'Driver',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                userName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.warningLight,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    userRating.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRideDetails(ThemeData theme) {
    return Column(
      children: [
        _buildDetailRow(
          theme,
          'pickup_location',
          'Pickup Location',
          rideData['pickupLocation'] as String,
        ),
        SizedBox(height: 1.5.h),
        _buildDetailRow(
          theme,
          'location_on',
          'Destination',
          rideData['destination'] as String,
        ),
        SizedBox(height: 1.5.h),
        _buildDetailRow(
          theme,
          'schedule',
          'Estimated Arrival',
          rideData['estimatedArrival'] as String,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
      ThemeData theme,
      String iconName,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverActions(ThemeData theme) {
    return Column(
      children: [
        if (rideData['status'] == 'En Route to Pickup')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onMarkPickedUp,
              icon: CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Mark Passenger Picked Up'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),

        if (rideData['status'] == 'Passenger Aboard' ||
            rideData['status'] == 'Approaching Destination')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCompleteRide,
              icon: CustomIconWidget(
                iconName: 'flag',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Complete Ride'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPassengerActions(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShareLocation,
                icon: CustomIconWidget(
                  iconName: 'share_location',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: const Text('Share Location'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onReportIssue,
                icon: CustomIconWidget(
                  iconName: 'report_problem',
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                label: const Text('Report Issue'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  side: BorderSide(color: theme.colorScheme.error),
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
