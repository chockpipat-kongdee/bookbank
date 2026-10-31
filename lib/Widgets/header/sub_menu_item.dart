// ────────── Package Imports ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ────────── Local Imports ──────────
import 'package:bookbank/core/theme/app_theme.dart';

// ────────── Sub Menu Item Widget ──────────
class SubMenuItem extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  const SubMenuItem({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentTheme = Theme.of(context);

        // ────────── InkWell with rounded corners ──────────
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? currentTheme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                // Flag
                Text(
                  flag,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: currentTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 8.w),

                // Label
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? currentTheme.colorScheme.primary
                          : currentTheme.colorScheme.onSurface,
                    ),
                  ),
                ),

                // Check icon (only shown when selected)
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14.sp,
                    color: currentTheme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
