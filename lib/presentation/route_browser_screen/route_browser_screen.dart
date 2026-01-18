import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/route_card_widget.dart';
import './widgets/route_filter_chip_widget.dart';

class RouteBrowserScreen extends StatefulWidget {
  const RouteBrowserScreen({super.key});

  @override
  State<RouteBrowserScreen> createState() => _RouteBrowserScreenState();
}

class _RouteBrowserScreenState extends State<RouteBrowserScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasLocationPermission = false;
  String _currentLocation = 'Detecting location...';

  Map<String, dynamic> _activeFilters = {
    'timeRange': null,
    'priceRange': null,
    'seats': null,
    'minRating': null,
    'sortBy': 'departureTime',
  };

  final List<Map<String, dynamic>> _mockRoutes = [
    {
      'id': 1,
      'driverName': 'Sarah Johnson',
      'driverPhoto':
      'https://img.rocket.new/generatedImages/rocket_gen_img_14da91c34-1763294780479.png',
      'driverPhotoLabel':
      'Professional woman with shoulder-length brown hair wearing a blue blazer, smiling at camera',
      'rating': 4.8,
      'totalRides': 156,
      'startLocation': '123 Main Street, Downtown',
      'destination': 'Tech Park Business District',
      'departureTime': 'Today, 8:30 AM',
      'availableSeats': 3,
      'pricePerSeat': 12,
      'estimatedDuration': '25 min',
      'distance': '8.5 mi',
      'walkingDistance': '0.3 mi',
      'departureHour': 8,
    },
    {
      'id': 2,
      'driverName': 'Michael Chen',
      'driverPhoto':
      'https://img.rocket.new/generatedImages/rocket_gen_img_197a755df-1763296026605.png',
      'driverPhotoLabel':
      'Asian man with short black hair and glasses wearing a gray polo shirt, professional headshot',
      'rating': 4.9,
      'totalRides': 203,
      'startLocation': 'Central Station Plaza',
      'destination': 'University Campus North',
      'departureTime': 'Today, 9:00 AM',
      'availableSeats': 2,
      'pricePerSeat': 8,
      'estimatedDuration': '18 min',
      'distance': '6.2 mi',
      'walkingDistance': '0.5 mi',
      'departureHour': 9,
    },
    {
      'id': 3,
      'driverName': 'Emily Rodriguez',
      'driverPhoto':
      'https://img.rocket.new/generatedImages/rocket_gen_img_11984bfac-1763296141464.png',
      'driverPhotoLabel':
      'Hispanic woman with long dark hair wearing a white blouse, friendly smile in outdoor setting',
      'rating': 4.7,
      'totalRides': 89,
      'startLocation': 'Riverside Shopping Mall',
      'destination': 'Airport Terminal 2',
      'departureTime': 'Today, 10:30 AM',
      'availableSeats': 4,
      'pricePerSeat': 25,
      'estimatedDuration': '35 min',
      'distance': '15.3 mi',
      'walkingDistance': '0.2 mi',
      'departureHour': 10,
    },
    {
      'id': 4,
      'driverName': 'David Thompson',
      'driverPhoto':
      'https://images.unsplash.com/photo-1643200372321-aed6201db08c',
      'driverPhotoLabel':
      'Caucasian man with short blonde hair and beard wearing a black t-shirt, casual outdoor photo',
      'rating': 4.6,
      'totalRides': 124,
      'startLocation': 'Oak Street Residential',
      'destination': 'Medical Center Complex',
      'departureTime': 'Today, 7:45 AM',
      'availableSeats': 1,
      'pricePerSeat': 10,
      'estimatedDuration': '22 min',
      'distance': '7.8 mi',
      'walkingDistance': '0.4 mi',
      'departureHour': 7,
    },
    {
      'id': 5,
      'driverName': 'Jessica Williams',
      'driverPhoto':
      'https://img.rocket.new/generatedImages/rocket_gen_img_17faa8e7a-1763295754680.png',
      'driverPhotoLabel':
      'African American woman with curly hair wearing a red sweater, warm smile in professional setting',
      'rating': 5.0,
      'totalRides': 178,
      'startLocation': 'Suburban Train Station',
      'destination': 'Downtown Financial District',
      'departureTime': 'Today, 8:00 AM',
      'availableSeats': 2,
      'pricePerSeat': 15,
      'estimatedDuration': '30 min',
      'distance': '12.1 mi',
      'walkingDistance': '0.6 mi',
      'departureHour': 8,
    },
  ];

  List<Map<String, dynamic>> _filteredRoutes = [];

  @override
  void initState() {
    super.initState();
    _filteredRoutes = List.from(_mockRoutes);
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        setState(() {
          _hasLocationPermission = true;
          _currentLocation = 'Current Location';
        });
      } else {
        setState(() {
          _currentLocation = 'Location access denied';
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Unable to detect location';
      });
    }
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
      _filteredRoutes = _mockRoutes.where((route) {
        final timeRange = filters['timeRange'] as RangeValues?;
        final priceRange = filters['priceRange'] as RangeValues?;
        final seats = filters['seats'] as int?;
        final minRating = filters['minRating'] as double?;

        if (timeRange != null) {
          final hour = route['departureHour'] as int;
          if (hour < timeRange.start || hour > timeRange.end) return false;
        }

        if (priceRange != null) {
          final price = route['pricePerSeat'] as int;
          if (price < priceRange.start || price > priceRange.end) return false;
        }

        if (seats != null && (route['availableSeats'] as int) < seats) {
          return false;
        }

        if (minRating != null && (route['rating'] as double) < minRating) {
          return false;
        }

        return true;
      }).toList();

      final sortBy = filters['sortBy'] as String;
      _filteredRoutes.sort((a, b) {
        switch (sortBy) {
          case 'price':
            return (a['pricePerSeat'] as int).compareTo(
              b['pricePerSeat'] as int,
            );
          case 'rating':
            return (b['rating'] as double).compareTo(a['rating'] as double);
          case 'distance':
            return (a['distance'] as String).compareTo(b['distance'] as String);
          default:
            return (a['departureHour'] as int).compareTo(
              b['departureHour'] as int,
            );
        }
      });
    });
  }

  void _clearFilters() {
    setState(() {
      _activeFilters = {
        'timeRange': null,
        'priceRange': null,
        'seats': null,
        'minRating': null,
        'sortBy': 'departureTime',
      };
      _filteredRoutes = List.from(_mockRoutes);
    });
  }

  bool _hasActiveFilters() {
    return _activeFilters['timeRange'] != null ||
        _activeFilters['priceRange'] != null ||
        _activeFilters['seats'] != null ||
        _activeFilters['minRating'] != null;
  }

  Future<void> _refreshRoutes() async {
    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _filteredRoutes = List.from(_mockRoutes);
      _isLoading = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onApplyFilters: _applyFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          color: theme.colorScheme.surface,
          padding: EdgeInsets.fromLTRB(16, 48, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Where are you going?',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: CustomIconWidget(
                              iconName: 'search',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 24,
                            ),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: CustomIconWidget(
                              iconName: 'close',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _searchController.clear());
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: CustomIconWidget(
                        iconName: 'tune',
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'my_location',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _currentLocation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_hasActiveFilters())
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (_activeFilters['timeRange'] != null)
                  RouteFilterChipWidget(
                    label:
                    'Time: ${(_activeFilters['timeRange'] as RangeValues).start.round()}:00-${(_activeFilters['timeRange'] as RangeValues).end.round()}:00',
                    isSelected: true,
                    onTap: () {
                      setState(() {
                        _activeFilters['timeRange'] = null;
                        _applyFilters(_activeFilters);
                      });
                    },
                    icon: Icons.schedule,
                  ),
                if (_activeFilters['priceRange'] != null) ...[
                  SizedBox(width: 8),
                  RouteFilterChipWidget(
                    label:
                    'Price: \$${(_activeFilters['priceRange'] as RangeValues).start.round()}-\$${(_activeFilters['priceRange'] as RangeValues).end.round()}',
                    isSelected: true,
                    onTap: () {
                      setState(() {
                        _activeFilters['priceRange'] = null;
                        _applyFilters(_activeFilters);
                      });
                    },
                    icon: Icons.attach_money,
                  ),
                ],
                if (_activeFilters['seats'] != null) ...[
                  SizedBox(width: 8),
                  RouteFilterChipWidget(
                    label: '${_activeFilters['seats']} seats',
                    isSelected: true,
                    onTap: () {
                      setState(() {
                        _activeFilters['seats'] = null;
                        _applyFilters(_activeFilters);
                      });
                    },
                    icon: Icons.event_seat,
                  ),
                ],
                if (_activeFilters['minRating'] != null &&
                    (_activeFilters['minRating'] as double) > 0) ...[
                  SizedBox(width: 8),
                  RouteFilterChipWidget(
                    label:
                    'Rating: ${(_activeFilters['minRating'] as double).toStringAsFixed(1)}+',
                    isSelected: true,
                    onTap: () {
                      setState(() {
                        _activeFilters['minRating'] = null;
                        _applyFilters(_activeFilters);
                      });
                    },
                    icon: Icons.star,
                  ),
                ],
              ],
            ),
          ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _filteredRoutes.isEmpty
              ? EmptyStateWidget(
            type: _hasActiveFilters() ? 'noFilters' : 'noRoutes',
            onAction: _hasActiveFilters() ? _clearFilters : null,
          )
              : RefreshIndicator(
            onRefresh: _refreshRoutes,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              itemCount: _filteredRoutes.length,
              itemBuilder: (context, index) {
                return RouteCardWidget(
                  routeData: _filteredRoutes[index],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening route details...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  onSaveRoute: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Route saved to favorites'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onMessageDriver: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Opening chat with ${_filteredRoutes[index]['driverName']}...',
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
