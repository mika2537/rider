import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom sheet widget for comprehensive route filtering
class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late RangeValues _timeRange;
  late RangeValues _priceRange;
  late int _selectedSeats;
  late double _minRating;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _timeRange =
        widget.currentFilters['timeRange'] as RangeValues? ??
            RangeValues(0, 24);
    _priceRange =
        widget.currentFilters['priceRange'] as RangeValues? ??
            RangeValues(0, 100);
    _selectedSeats = widget.currentFilters['seats'] as int? ?? 1;
    _minRating = widget.currentFilters['minRating'] as double? ?? 0.0;
    _sortBy = widget.currentFilters['sortBy'] as String? ?? 'departureTime';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Routes',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _timeRange = RangeValues(0, 24);
                          _priceRange = RangeValues(0, 100);
                          _selectedSeats = 1;
                          _minRating = 0.0;
                          _sortBy = 'departureTime';
                        });
                      },
                      child: Text('Reset'),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  'Departure Time',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                RangeSlider(
                  values: _timeRange,
                  min: 0,
                  max: 24,
                  divisions: 24,
                  labels: RangeLabels(
                    '${_timeRange.start.round()}:00',
                    '${_timeRange.end.round()}:00',
                  ),
                  onChanged: (values) {
                    setState(() => _timeRange = values);
                  },
                ),
                Text(
                  '${_timeRange.start.round()}:00 - ${_timeRange.end.round()}:00',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Price Range',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  labels: RangeLabels(
                    '\$${_priceRange.start.round()}',
                    '\$${_priceRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() => _priceRange = values);
                  },
                ),
                Text(
                  '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Available Seats',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: List.generate(4, (index) {
                    final seats = index + 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
                        child: ChoiceChip(
                          label: Text('$seats'),
                          selected: _selectedSeats == seats,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedSeats = seats);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24),
                Text(
                  'Minimum Driver Rating',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: _minRating.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => _minRating = value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Any',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _minRating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  'Sort By',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Departure Time'),
                      selected: _sortBy == 'departureTime',
                      onSelected: (selected) {
                        if (selected) setState(() => _sortBy = 'departureTime');
                      },
                    ),
                    ChoiceChip(
                      label: Text('Price'),
                      selected: _sortBy == 'price',
                      onSelected: (selected) {
                        if (selected) setState(() => _sortBy = 'price');
                      },
                    ),
                    ChoiceChip(
                      label: Text('Rating'),
                      selected: _sortBy == 'rating',
                      onSelected: (selected) {
                        if (selected) setState(() => _sortBy = 'rating');
                      },
                    ),
                    ChoiceChip(
                      label: Text('Distance'),
                      selected: _sortBy == 'distance',
                      onSelected: (selected) {
                        if (selected) setState(() => _sortBy = 'distance');
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters({
                        'timeRange': _timeRange,
                        'priceRange': _priceRange,
                        'seats': _selectedSeats,
                        'minRating': _minRating,
                        'sortBy': _sortBy,
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
