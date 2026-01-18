import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/profile_management_screen/profile_management_screen.dart';
import '../presentation/driver_dashboard/driver_dashboard.dart';
import '../presentation/ride_tracking_screen/ride_tracking_screen.dart';
import '../presentation/create_route_screen/create_route_screen.dart';
import '../presentation/route_browser_screen/route_browser_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String profileManagement = '/profile-management-screen';
  static const String driverDashboard = '/driver-dashboard';
  static const String rideTracking = '/ride-tracking-screen';
  static const String createRoute = '/create-route-screen';
  static const String routeBrowser = '/route-browser-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    profileManagement: (context) => const ProfileManagementScreen(),
    driverDashboard: (context) => const DriverDashboard(),
    rideTracking: (context) => const RideTrackingScreen(),
    createRoute: (context) => const CreateRouteScreen(),
    routeBrowser: (context) => const RouteBrowserScreen(),
    // TODO: Add your other routes here
  };
}
