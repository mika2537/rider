import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/emergency_sos_button.dart';
import './widgets/ride_info_bottom_sheet.dart';

/// Ride Tracking Screen - Real-time GPS monitoring and ride management
/// Provides live location tracking, route visualization, and ride controls
class RideTrackingScreen extends StatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Current location
  LatLng _currentPosition = const LatLng(
    37.7749,
    -122.4194,
  ); // San Francisco default

  // Map markers
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Ride state
  final bool _isDriver = true; // Mock: Toggle between driver/passenger view
  bool _isLocationSharing = false;
  bool _isLoading = true;

  // Mock ride data
  final Map<String, dynamic> _rideData = {
    'status': 'En Route to Pickup',
    'driverName': 'Michael Rodriguez',
    'driverImage':
    'https://img.rocket.new/generatedImages/rocket_gen_img_1eb825b5d-1763292809998.png',
    'driverSemanticLabel':
    'Professional headshot of Hispanic man with short dark hair wearing navy blue shirt',
    'driverRating': 4.8,
    'passengerName': 'Sarah Johnson',
    'passengerImage':
    'https://img.rocket.new/generatedImages/rocket_gen_img_1e9a2995d-1763296922897.png',
    'passengerSemanticLabel':
    'Professional headshot of woman with blonde hair wearing white blouse',
    'passengerRating': 4.9,
    'pickupLocation': '123 Market Street, San Francisco, CA',
    'destination': '456 Mission Street, San Francisco, CA',
    'estimatedArrival': '10 minutes',
  };

  // Route coordinates (mock route path)
  final List<LatLng> _routeCoordinates = [
    const LatLng(37.7749, -122.4194),
    const LatLng(37.7849, -122.4094),
    const LatLng(37.7949, -122.3994),
    const LatLng(37.8049, -122.3894),
  ];

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permissions are required for ride tracking');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied');
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Initialize markers and route
      _setupMapElements();

      // Start location tracking
      _startLocationTracking();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to initialize location tracking');
    }
  }

  void _setupMapElements() {
    // Add current location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Current Location'),
      ),
    );

    // Add pickup marker
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: _routeCoordinates.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
    );

    // Add destination marker
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: _routeCoordinates.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destination'),
      ),
    );

    // Add route polyline
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routeCoordinates,
        color: AppTheme.primaryLight,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );

    setState(() {});
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position position) {
          final newPosition = LatLng(position.latitude, position.longitude);

          setState(() {
            _currentPosition = newPosition;

            // Update current location marker
            _markers.removeWhere((m) => m.markerId.value == 'current_location');
            _markers.add(
              Marker(
                markerId: const MarkerId('current_location'),
                position: newPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                infoWindow: const InfoWindow(title: 'Current Location'),
              ),
            );
          });

          // Animate camera to new position
          _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
        });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Fit bounds to show entire route
    if (_routeCoordinates.isNotEmpty) {
      final bounds = _calculateBounds(_routeCoordinates);
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> coordinates) {
    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLng) minLng = coord.longitude;
      if (coord.longitude > maxLng) maxLng = coord.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _handleEmergency() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'emergency',
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'Emergency services will be notified and your location will be shared with your emergency contacts. Do you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerEmergency();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Confirm Emergency'),
          ),
        ],
      ),
    );
  }

  void _triggerEmergency() {
    // Mock emergency trigger
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            const Expanded(
              child: Text(
                'Emergency services notified. Location shared with emergency contacts.',
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleMarkPickedUp() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Pickup'),
        content: const Text('Have you picked up the passenger?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _rideData['status'] = 'Passenger Aboard';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Passenger marked as picked up'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _handleCompleteRide() {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Ride'),
        content: const Text(
          'Have you reached the destination? This will end the ride and proceed to payment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _positionStreamSubscription?.cancel();

              // Navigate to payment/rating screen (mock)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ride completed! Proceeding to payment...'),
                  duration: Duration(seconds: 2),
                ),
              );

              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushReplacementNamed('/driver-dashboard');
                }
              });
            },
            child: const Text('Complete Ride'),
          ),
        ],
      ),
    );
  }

  void _handleShareLocation() {
    HapticFeedback.lightImpact();

    setState(() {
      _isLocationSharing = !_isLocationSharing;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLocationSharing
              ? 'Live location sharing enabled'
              : 'Live location sharing disabled',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleReportIssue() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'warning',
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              title: const Text('Safety Concern'),
              onTap: () {
                Navigator.pop(context);
                _showIssueReported('Safety concern');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'directions_car',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Route Issue'),
              onTap: () {
                Navigator.pop(context);
                _showIssueReported('Route issue');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: const Text('Driver Behavior'),
              onTap: () {
                Navigator.pop(context);
                _showIssueReported('Driver behavior');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showIssueReported(String issueType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$issueType reported. Support team will review shortly.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            SizedBox(height: 2.h),
            Text(
              'Initializing GPS tracking...',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      )
          : Stack(
        children: [
          // Google Maps
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            trafficEnabled: false,
            buildingsEnabled: true,
          ),

          // Top overlay - Emergency SOS button
          Positioned(
            top: MediaQuery.of(context).padding.top + 2.h,
            right: 4.w,
            child: EmergencySosButton(onPressed: _handleEmergency),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 2.h,
            left: 4.w,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // My location button
          Positioned(
            bottom: 35.h,
            right: 4.w,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: CustomIconWidget(
                  iconName: 'my_location',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                onPressed: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(_currentPosition),
                  );
                },
              ),
            ),
          ),

          // Bottom sheet with ride information
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.25,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: RideInfoBottomSheet(
                  rideData: _rideData,
                  isDriver: _isDriver,
                  onEmergency: _handleEmergency,
                  onMarkPickedUp: _isDriver ? _handleMarkPickedUp : null,
                  onCompleteRide: _isDriver ? _handleCompleteRide : null,
                  onShareLocation: !_isDriver
                      ? _handleShareLocation
                      : null,
                  onReportIssue: !_isDriver ? _handleReportIssue : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
