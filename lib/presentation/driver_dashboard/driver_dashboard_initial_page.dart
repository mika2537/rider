import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/active_route_card_widget.dart';
import './widgets/passenger_request_card_widget.dart';
import './widgets/quick_stats_card_widget.dart';

class DriverDashboardInitialPage extends StatefulWidget {
  const DriverDashboardInitialPage({super.key});

  @override
  State<DriverDashboardInitialPage> createState() =>
      _DriverDashboardInitialPageState();
}

class _DriverDashboardInitialPageState
    extends State<DriverDashboardInitialPage> {
  bool _isRefreshing = false;

  // Mock data for driver dashboard
  final Map<String, dynamic> driverData = {
    "name": "Michael Rodriguez",
    "currentEarnings": "\$245.50",
    "todayEarnings": "\$89.25",
    "completedRides": 12,
    "passengerRating": 4.8,
    "hasActiveRoute": true,
    "activeRoute": {
      "startLocation": "Downtown Plaza",
      "destination": "Airport Terminal 3",
      "departureTime": "2:30 PM",
      "availableSeats": 2,
      "totalSeats": 4,
    },
  };

  final List<Map<String, dynamic>> pendingRequests = [
    {
      "id": 1,
      "passengerName": "Sarah Johnson",
      "passengerPhoto":
      "https://img.rocket.new/generatedImages/rocket_gen_img_149f3bcac-1763298667408.png",
      "semanticLabel":
      "Profile photo of a woman with long brown hair wearing a blue shirt, smiling at the camera.",
      "pickupLocation": "Central Station",
      "requestTime": "10 mins ago",
      "rating": 4.9,
      "completedRides": 45,
    },
    {
      "id": 2,
      "passengerName": "David Chen",
      "passengerPhoto":
      "https://img.rocket.new/generatedImages/rocket_gen_img_168fa4879-1763295787903.png",
      "semanticLabel":
      "Profile photo of an Asian man with short black hair and glasses, wearing a gray sweater.",
      "pickupLocation": "University Campus",
      "requestTime": "25 mins ago",
      "rating": 4.7,
      "completedRides": 32,
    },
    {
      "id": 3,
      "passengerName": "Emma Williams",
      "passengerPhoto":
      "https://img.rocket.new/generatedImages/rocket_gen_img_16160e5cd-1763294249246.png",
      "semanticLabel":
      "Profile photo of a blonde woman with shoulder-length hair wearing a white blouse, professional headshot.",
      "pickupLocation": "Business District",
      "requestTime": "1 hour ago",
      "rating": 5.0,
      "completedRides": 78,
    },
  ];

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  void _handleApproveRequest(int requestId) {
    setState(() {
      pendingRequests.removeWhere(
            (request) => (request["id"] as int) == requestId,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Passenger request approved'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDeclineRequest(int requestId) {
    setState(() {
      pendingRequests.removeWhere(
            (request) => (request["id"] as int) == requestId,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Passenger request declined'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleCreateRoute() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/create-route-screen');
  }

  void _handleManageRoute() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/create-route-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  driverData["name"] as String,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'notifications_outlined',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
              SizedBox(width: 2.w),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Earnings Summary Card
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Earnings',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        driverData["currentEarnings"] as String,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Active Route Section
                if (driverData["hasActiveRoute"] as bool) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Route',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: _handleManageRoute,
                          child: Text(
                            'Manage',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ActiveRouteCardWidget(
                    routeData:
                    driverData["activeRoute"] as Map<String, dynamic>,
                    onManageRoute: _handleManageRoute,
                  ),
                ],

                // Passenger Requests Section
                if (pendingRequests.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Text(
                      'Passenger Requests',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: pendingRequests.length,
                    itemBuilder: (context, index) {
                      return PassengerRequestCardWidget(
                        requestData: pendingRequests[index],
                        onApprove: () => _handleApproveRequest(
                          pendingRequests[index]["id"] as int,
                        ),
                        onDecline: () => _handleDeclineRequest(
                          pendingRequests[index]["id"] as int,
                        ),
                      );
                    },
                  ),
                ],

                // Quick Stats Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Text(
                    'Today\'s Stats',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                QuickStatsCardWidget(
                  todayEarnings: driverData["todayEarnings"] as String,
                  completedRides: driverData["completedRides"] as int,
                  passengerRating: driverData["passengerRating"] as double,
                ),

                // Empty State for No Active Route
                if (!(driverData["hasActiveRoute"] as bool)) ...[
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 4.h,
                    ),
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'route',
                          color: theme.colorScheme.primary,
                          size: 64,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No Active Route',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Create your first route to start earning',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 3.h),
                        ElevatedButton.icon(
                          onPressed: _handleCreateRoute,
                          icon: CustomIconWidget(
                            iconName: 'add',
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                          label: const Text('Create Route'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 1.5.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
