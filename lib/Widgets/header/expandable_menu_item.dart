import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:bookbank/core/theme/app_theme.dart';

// ────────── Expandable Menu Item Widget ──────────
class ExpandableMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String badge;
  final ThemeData theme;
  final List<Widget> children;

  const ExpandableMenuItem({
    required this.icon,
    required this.label,
    required this.badge,
    required this.theme,
    required this.children,
    super.key,
  });

  @override
  State<ExpandableMenuItem> createState() => ExpandableMenuItemState();
}

// ────────── Expandable Menu Item State ──────────
class ExpandableMenuItemState extends State<ExpandableMenuItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _arrowAngle;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Arrow Angle Animation
    _arrowAngle = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Expand Animation
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Toggle expand/collapse
  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  // Build the widget
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentTheme = Theme.of(context);
        return Column(
          children: [
            // ────────── Main Menu Item ──────────
            InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    // Icon
                    Icon(
                      widget.icon,
                      size: 16.sp,
                      color: currentTheme.colorScheme.onSurface,
                    ),
                    SizedBox(width: 10.w),

                    // Label
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: currentTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: currentTheme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        widget.badge,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: currentTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),

                    // Arrow Icon
                    RotationTransition(
                      turns: _arrowAngle,
                      child: Icon(
                        Icons.expand_more,
                        size: 16.sp,
                        color: currentTheme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ────────── Expanded Content ──────────
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                margin: EdgeInsets.only(left: 16.w, right: 8.w, bottom: 4.h),
                decoration: BoxDecoration(
                  color: currentTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: currentTheme.colorScheme.outline.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
                child: Column(children: widget.children),
              ),
            ),
          ],
        );
      },
    );
  }
}
