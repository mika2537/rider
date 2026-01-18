import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/advanced_options_widget.dart';
import './widgets/location_input_widget.dart';
import './widgets/price_input_widget.dart';
import './widgets/recurring_route_widget.dart';
import './widgets/seat_selector_widget.dart';
import './widgets/time_selection_widget.dart';

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Form controllers
  final TextEditingController _startLocationController =
  TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final List<TextEditingController> _waypointControllers = [];

  // Route data
  LatLng? _startLatLng;
  LatLng? _destinationLatLng;
  final List<LatLng> _waypoints = [];
  DateTime? _selectedDateTime;
  int _selectedSeats = 1;
  double _pricePerSeat = 0.0;
  bool _isRecurring = false;
  List<int> _selectedDays = [];
  String _genderPreference = 'Any';
  String _ageRange = 'Any';
  bool _smokingAllowed = false;
  String _specialInstructions = '';

  // UI state
  bool _isLoadingLocation = true;
  bool _showAdvancedOptions = false;
  String? _routeDistance;
  String? _routeDuration;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _startLocationController.dispose();
    _destinationController.dispose();
    for (var controller in _waypointControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _startLatLng = LatLng(position.latitude, position.longitude);
        _startLocationController.text = 'Current Location';
        _isLoadingLocation = false;

        _markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'Start Location'),
          ),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14.0,
        ),
      );
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _updateDestination(LatLng location, String address) {
    setState(() {
      _destinationLatLng = location;
      _destinationController.text = address;

      _markers.removeWhere((marker) => marker.markerId.value == 'destination');
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
      );

      if (_startLatLng != null) {
        _drawRoute();
      }
    });
  }

  void _addWaypoint() {
    setState(() {
      _waypointControllers.add(TextEditingController());
    });
  }

  void _removeWaypoint(int index) {
    setState(() {
      _waypointControllers[index].dispose();
      _waypointControllers.removeAt(index);
      if (index < _waypoints.length) {
        _waypoints.removeAt(index);
        _markers.removeWhere(
              (marker) => marker.markerId.value == 'waypoint_$index',
        );
        _drawRoute();
      }
    });
  }

  void _drawRoute() {
    if (_startLatLng == null || _destinationLatLng == null) return;

    final List<LatLng> routePoints = [
      _startLatLng!,
      ..._waypoints,
      _destinationLatLng!,
    ];

    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: Theme.of(context).colorScheme.primary,
          width: 4,
        ),
      );

      _calculateRouteDetails(routePoints);
    });

    if (routePoints.length >= 2) {
      _fitMapToBounds(routePoints);
    }
  }

  void _calculateRouteDetails(List<LatLng> points) {
    double totalDistance = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }

    final distanceInMiles = totalDistance / 1609.34;
    final estimatedMinutes = (distanceInMiles / 40) * 60;

    setState(() {
      _routeDistance = '${distanceInMiles.toStringAsFixed(1)} miles';
      _routeDuration = '${estimatedMinutes.toStringAsFixed(0)} min';

      if (_pricePerSeat == 0.0) {
        _pricePerSeat = (distanceInMiles * 0.5).roundToDouble();
      }
    });
  }

  void _fitMapToBounds(List<LatLng> points) {
    if (points.isEmpty) return;

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100,
      ),
    );
  }

  Future<void> _publishRoute() async {
    if (_startLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a start location')),
      );
      return;
    }

    if (_destinationLatLng == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please set a destination')));
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select departure time')),
      );
      return;
    }

    if (_pricePerSeat <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a valid price per seat')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error publishing route: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _cancelRoute() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Route', style: theme.appBarTheme.titleTextStyle),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            color:
            theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: _cancelRoute,
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _publishRoute,
            child: _isSaving
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            )
                : Text(
              'Publish',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingLocation
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Getting your location...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      )
          : Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              )
                  : const LatLng(37.7749, -122.4194),
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: !kIsWeb,
            mapToolbarEnabled: false,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LocationInputWidget(
                      startController: _startLocationController,
                      destinationController: _destinationController,
                      waypointControllers: _waypointControllers,
                      onDestinationSelected: _updateDestination,
                      onAddWaypoint: _addWaypoint,
                      onRemoveWaypoint: _removeWaypoint,
                    ),
                    if (_routeDistance != null &&
                        _routeDuration != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'straighten',
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _routeDistance!,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _routeDuration!,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TimeSelectionWidget(
                      selectedDateTime: _selectedDateTime,
                      onDateTimeSelected: (dateTime) {
                        setState(() => _selectedDateTime = dateTime);
                      },
                    ),
                    const SizedBox(height: 24),
                    SeatSelectorWidget(
                      selectedSeats: _selectedSeats,
                      onSeatsChanged: (seats) {
                        setState(() => _selectedSeats = seats);
                      },
                    ),
                    const SizedBox(height: 24),
                    PriceInputWidget(
                      pricePerSeat: _pricePerSeat,
                      suggestedPrice: _routeDistance != null
                          ? (double.parse(_routeDistance!.split(' ')[0]) *
                          0.5)
                          .roundToDouble()
                          : null,
                      onPriceChanged: (price) {
                        setState(() => _pricePerSeat = price);
                      },
                    ),
                    const SizedBox(height: 24),
                    RecurringRouteWidget(
                      isRecurring: _isRecurring,
                      selectedDays: _selectedDays,
                      onRecurringChanged: (value) {
                        setState(() => _isRecurring = value);
                      },
                      onDaysChanged: (days) {
                        setState(() => _selectedDays = days);
                      },
                    ),
                    const SizedBox(height: 24),
                    AdvancedOptionsWidget(
                      isExpanded: _showAdvancedOptions,
                      genderPreference: _genderPreference,
                      ageRange: _ageRange,
                      smokingAllowed: _smokingAllowed,
                      specialInstructions: _specialInstructions,
                      onExpandChanged: (value) {
                        setState(() => _showAdvancedOptions = value);
                      },
                      onGenderChanged: (value) {
                        setState(() => _genderPreference = value);
                      },
                      onAgeRangeChanged: (value) {
                        setState(() => _ageRange = value);
                      },
                      onSmokingChanged: (value) {
                        setState(() => _smokingAllowed = value);
                      },
                      onInstructionsChanged: (value) {
                        setState(() => _specialInstructions = value);
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _publishRoute,
                        child: _isSaving
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : Text(
                          'Publish Route',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
