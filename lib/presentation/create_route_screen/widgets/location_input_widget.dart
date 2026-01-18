import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LocationInputWidget extends StatelessWidget {
  final TextEditingController startController;
  final TextEditingController destinationController;
  final List<TextEditingController> waypointControllers;
  final Function(LatLng, String) onDestinationSelected;
  final VoidCallback onAddWaypoint;
  final Function(int) onRemoveWaypoint;

  const LocationInputWidget({
    super.key,
    required this.startController,
    required this.destinationController,
    required this.waypointControllers,
    required this.onDestinationSelected,
    required this.onAddWaypoint,
    required this.onRemoveWaypoint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor, width: 1),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: startController,
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Start Location',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              if (waypointControllers.isNotEmpty)
                ...List.generate(waypointControllers.length, (index) {
                  return Column(
                    children: [
                      Divider(height: 1, color: theme.dividerColor),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: waypointControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Waypoint ${index + 1}',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color:
                                    theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                style: theme.textTheme.bodyMedium,
                                onTap: () =>
                                    _showLocationSearch(context, index),
                                readOnly: true,
                              ),
                            ),
                            IconButton(
                              icon: CustomIconWidget(
                                iconName: 'close',
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              onPressed: () => onRemoveWaypoint(index),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              Divider(height: 1, color: theme.dividerColor),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: destinationController,
                        decoration: InputDecoration(
                          hintText: 'Destination',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium,
                        onTap: () => _showLocationSearch(context, -1),
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: waypointControllers.length < 3 ? onAddWaypoint : null,
          icon: CustomIconWidget(
            iconName: 'add_circle_outline',
            color: waypointControllers.length < 3
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          label: Text(
            'Add Stop',
            style: theme.textTheme.labelLarge?.copyWith(
              color: waypointControllers.length < 3
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  void _showLocationSearch(BuildContext context, int waypointIndex) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> mockLocations = [
      {
        "name": "San Francisco International Airport",
        "address": "San Francisco, CA 94128",
        "lat": 37.6213,
        "lng": -122.3790,
      },
      {
        "name": "Golden Gate Bridge",
        "address": "Golden Gate Bridge, San Francisco, CA",
        "lat": 37.8199,
        "lng": -122.4783,
      },
      {
        "name": "Union Square",
        "address": "333 Post St, San Francisco, CA 94108",
        "lat": 37.7880,
        "lng": -122.4075,
      },
      {
        "name": "Fisherman's Wharf",
        "address": "Fisherman's Wharf, San Francisco, CA",
        "lat": 37.8080,
        "lng": -122.4177,
      },
      {
        "name": "Stanford University",
        "address": "450 Serra Mall, Stanford, CA 94305",
        "lat": 37.4275,
        "lng": -122.1697,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomIconWidget(
                            iconName: 'search',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: mockLocations.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: theme.dividerColor),
                itemBuilder: (context, index) {
                  final location = mockLocations[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'place',
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ),
                    title: Text(
                      location["name"] as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      location["address"] as String,
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () {
                      final latLng = LatLng(
                        location["lat"] as double,
                        location["lng"] as double,
                      );
                      onDestinationSelected(latLng, location["name"] as String);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
