import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen provides branded app launch experience while initializing
/// Firebase services and determining user authentication status for navigation routing.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isInitializing = true;
  String _initializationStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate Firebase initialization
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _initializationStatus = 'Checking authentication...');
      }

      // Simulate authentication check
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _initializationStatus = 'Loading preferences...');
      }

      // Simulate loading user preferences
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _initializationStatus = 'Preparing data...');
      }

      // Simulate data preparation
      await Future.delayed(const Duration(milliseconds: 500));

      // Wait for animation to complete
      await _animationController.forward();

      if (mounted) {
        setState(() => _isInitializing = false);
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initializationStatus = 'Initialization failed';
        });
        _showRetryOption();
      }
    }
  }

  void _navigateToNextScreen() {
    // Simulate authentication status check
    // For demo purposes, navigate to driver dashboard
    // In production, this would check actual auth status and user role
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/driver-dashboard');
      }
    });
  }

  void _showRetryOption() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: const Text(
          'Unable to initialize the app. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isInitializing = true;
                _initializationStatus = 'Retrying...';
              });
              _initializeApp();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildAnimatedLogo(theme),
              SizedBox(height: 4.h),
              _buildAppName(theme),
              SizedBox(height: 2.h),
              _buildTagline(theme),
              const Spacer(flex: 2),
              _buildLoadingIndicator(theme),
              SizedBox(height: 2.h),
              _buildStatusText(theme),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(ThemeData theme) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'directions_car',
                  size: 15.w,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Text(
            'UB Carpool',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Text(
            'Share Your Ride, Share Your Journey',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return _isInitializing
        ? SizedBox(
      width: 8.w,
      height: 8.w,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          theme.colorScheme.onPrimary,
        ),
      ),
    )
        : CustomIconWidget(
      iconName: 'check_circle',
      size: 8.w,
      color: theme.colorScheme.onPrimary,
    );
  }

  Widget _buildStatusText(ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _initializationStatus,
        key: ValueKey<String>(_initializationStatus),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
