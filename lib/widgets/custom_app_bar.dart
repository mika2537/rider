import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar for the ride-sharing application.
/// Implements clean, professional design with contextual actions.
///
/// Variants:
/// - Standard: Basic app bar with title and optional actions
/// - WithSearch: Includes search functionality
/// - WithBack: Includes back navigation
/// - Transparent: Transparent background for overlay scenarios
enum CustomAppBarVariant { standard, withSearch, withBack, transparent }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text to display
  final String title;

  /// App bar variant
  final CustomAppBarVariant variant;

  /// Optional leading widget (overrides default back button)
  final Widget? leading;

  /// Optional actions widgets
  final List<Widget>? actions;

  /// Optional search callback for withSearch variant
  final VoidCallback? onSearchTap;

  /// Optional back callback for withBack variant
  final VoidCallback? onBackTap;

  /// Whether to center the title
  final bool centerTitle;

  /// Optional elevation override
  final double? elevation;

  /// Optional background color override
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.leading,
    this.actions,
    this.onSearchTap,
    this.onBackTap,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    // Determine background color based on variant
    Color? effectiveBackgroundColor = backgroundColor;
    if (variant == CustomAppBarVariant.transparent) {
      effectiveBackgroundColor = Colors.transparent;
    } else {
      effectiveBackgroundColor ??= appBarTheme.backgroundColor;
    }

    // Determine elevation based on variant
    double effectiveElevation = elevation ?? appBarTheme.elevation ?? 2.0;
    if (variant == CustomAppBarVariant.transparent) {
      effectiveElevation = 0.0;
    }

    // Build leading widget based on variant
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && variant == CustomAppBarVariant.withBack) {
      effectiveLeading = IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackTap ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    // Build actions based on variant
    List<Widget>? effectiveActions = actions;
    if (variant == CustomAppBarVariant.withSearch) {
      effectiveActions = [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchTap,
          tooltip: 'Search',
        ),
        if (actions != null) ...actions!,
      ];
    }

    return AppBar(
      leading: effectiveLeading,
      title: Text(title, style: appBarTheme.titleTextStyle),
      centerTitle: centerTitle,
      actions: effectiveActions,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: appBarTheme.foregroundColor,
      elevation: effectiveElevation,
      shadowColor: appBarTheme.shadowColor,
      systemOverlayStyle: variant == CustomAppBarVariant.transparent
          ? SystemUiOverlayStyle.light
          : theme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
