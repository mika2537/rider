import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Profile header widget with photo, name, rating, and verification badges
class ProfileHeaderWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(String) onPhotoChanged;

  const ProfileHeaderWidget({
    super.key,
    required this.userData,
    required this.onPhotoChanged,
  });

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  XFile? _capturedImage;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      )
          : _cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {}

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {}
      }

      setState(() => _isCameraInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to initialize camera'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() => _capturedImage = photo);
      widget.onPhotoChanged(photo.path);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile photo updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to capture photo'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() => _capturedImage = image);
        widget.onPhotoChanged(image.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile photo updated successfully'),
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
            content: const Text('Failed to select photo'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final hasPermission = await _requestCameraPermission();
                if (hasPermission) {
                  await _initializeCamera();
                  if (mounted && _isCameraInitialized) {
                    _showCameraPreview();
                  }
                }
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCameraPreview() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 70.h,
          child: Column(
            children: [
              Expanded(
                child: _cameraController != null && _isCameraInitialized
                    ? CameraPreview(_cameraController!)
                    : Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        _cameraController?.dispose();
                        setState(() => _isCameraInitialized = false);
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'camera',
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _capturePhoto,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.userData['name'] as String? ?? 'User Name';
    final rating = widget.userData['rating'] as double? ?? 4.5;
    final photoUrl = widget.userData['photoUrl'] as String? ?? '';
    final isPhoneVerified = widget.userData['phoneVerified'] as bool? ?? true;
    final isEmailVerified = widget.userData['emailVerified'] as bool? ?? true;
    final isIdVerified = widget.userData['idVerified'] as bool? ?? false;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? CustomImageWidget(
                    imageUrl: photoUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    semanticLabel: 'User profile photo showing $name',
                  )
                      : Container(
                    width: 100,
                    height: 100,
                    color: theme.colorScheme.surface,
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: theme.colorScheme.onSurface,
                      size: 50,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(iconName: 'star', color: Colors.amber, size: 20),
              SizedBox(width: 1.w),
              Text(
                rating.toStringAsFixed(1),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPhoneVerified)
                _buildVerificationBadge(
                  theme: theme,
                  icon: 'phone',
                  label: 'Phone',
                ),
              if (isEmailVerified) ...[
                SizedBox(width: 2.w),
                _buildVerificationBadge(
                  theme: theme,
                  icon: 'email',
                  label: 'Email',
                ),
              ],
              if (isIdVerified) ...[
                SizedBox(width: 2.w),
                _buildVerificationBadge(
                  theme: theme,
                  icon: 'verified_user',
                  label: 'ID',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge({
    required ThemeData theme,
    required String icon,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: icon, color: Colors.white, size: 14),
          SizedBox(width: 1.w),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
