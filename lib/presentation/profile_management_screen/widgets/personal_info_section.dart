import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Personal Information section widget for profile management
/// Displays and allows editing of user's basic information
class PersonalInfoSection extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onSave;

  const PersonalInfoSection({
    super.key,
    required this.userData,
    required this.onSave,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _emergencyContactController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData['name'] as String? ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.userData['phone'] as String? ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userData['email'] as String? ?? '',
    );
    _emergencyContactController = TextEditingController(
      text: widget.userData['emergencyContact'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_validateInputs()) return;

    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 800));

    final updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'emergencyContact': _emergencyContactController.text.trim(),
    };

    widget.onSave(updatedData);

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Personal information updated successfully'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Name cannot be empty');
      return false;
    }
    if (_phoneController.text.trim().isEmpty ||
        _phoneController.text.trim().length < 10) {
      _showError('Please enter a valid phone number');
      return false;
    }
    if (_emailController.text.trim().isEmpty ||
        !_emailController.text.contains('@')) {
      _showError('Please enter a valid email address');
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
                  'Personal Information',
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
              controller: _nameController,
              label: 'Full Name',
              icon: 'person',
              enabled: _isEditing,
            ),
            SizedBox(height: 2.h),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: 'phone',
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 2.h),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: 'email',
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 2.h),
            _buildTextField(
              controller: _emergencyContactController,
              label: 'Emergency Contact',
              icon: 'contact_phone',
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            if (_isEditing) ...[
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                      : const Text('Save Changes'),
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
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
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
}
