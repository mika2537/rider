import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Vehicle Information section widget for driver profiles
/// Displays car details, license plate, and insurance document management
class VehicleInfoSection extends StatefulWidget {
  final Map<String, dynamic> vehicleData;
  final Function(Map<String, dynamic>) onUpdate;

  const VehicleInfoSection({
    super.key,
    required this.vehicleData,
    required this.onUpdate,
  });

  @override
  State<VehicleInfoSection> createState() => _VehicleInfoSectionState();
}

class _VehicleInfoSectionState extends State<VehicleInfoSection> {
  late TextEditingController _carModelController;
  late TextEditingController _licensePlateController;
  late TextEditingController _colorController;
  bool _isEditing = false;
  String? _insuranceFileName;

  @override
  void initState() {
    super.initState();
    _carModelController = TextEditingController(
      text: widget.vehicleData['carModel'] as String? ?? '',
    );
    _licensePlateController = TextEditingController(
      text: widget.vehicleData['licensePlate'] as String? ?? '',
    );
    _colorController = TextEditingController(
      text: widget.vehicleData['color'] as String? ?? '',
    );
    _insuranceFileName = widget.vehicleData['insuranceDocument'] as String?;
  }

  @override
  void dispose() {
    _carModelController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _uploadInsuranceDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _insuranceFileName = result.files.first.name;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Insurance document uploaded: ${result.files.first.name}',
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to upload document. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_validateInputs()) return;

    final updatedData = {
      'carModel': _carModelController.text.trim(),
      'licensePlate': _licensePlateController.text.trim().toUpperCase(),
      'color': _colorController.text.trim(),
      'insuranceDocument': _insuranceFileName,
    };

    widget.onUpdate(updatedData);

    setState(() => _isEditing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vehicle information updated successfully'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _validateInputs() {
    if (_carModelController.text.trim().isEmpty) {
      _showError('Car model cannot be empty');
      return false;
    }
    if (_licensePlateController.text.trim().isEmpty) {
      _showError('License plate cannot be empty');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: _isEditing ? 'close' : 'edit',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                  tooltip: _isEditing ? 'Cancel' : 'Edit',
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildTextField(
              controller: _carModelController,
              label: 'Car Model',
              icon: 'directions_car',
              enabled: _isEditing,
            ),
            SizedBox(height: 2.h),
            _buildTextField(
              controller: _licensePlateController,
              label: 'License Plate',
              icon: 'badge',
              enabled: _isEditing,
            ),
            SizedBox(height: 2.h),
            _buildTextField(
              controller: _colorController,
              label: 'Car Color',
              icon: 'palette',
              enabled: _isEditing,
            ),
            SizedBox(height: 2.h),
            _buildInsuranceSection(theme),
            if (_isEditing) ...[
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String icon,
    required bool enabled,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: icon,
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: !enabled,
        fillColor: enabled
            ? null
            : theme.colorScheme.surface.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildInsuranceSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'description',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text('Insurance Document', style: theme.textTheme.titleMedium),
            ],
          ),
          SizedBox(height: 1.h),
          if (_insuranceFileName != null) ...[
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: theme.colorScheme.tertiary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _insuranceFileName!,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
          ],
          if (_isEditing)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _uploadInsuranceDocument,
                icon: CustomIconWidget(
                  iconName: 'upload_file',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                label: Text(
                  _insuranceFileName == null
                      ? 'Upload Document'
                      : 'Replace Document',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
