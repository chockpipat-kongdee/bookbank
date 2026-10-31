// ────────── Package Imports ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ────────── Dark Theme Row Widget ──────────
import 'package:bookbank/core/theme/app_theme.dart';

// ────────── Widget Definition ──────────
class DarkThemeRow extends StatelessWidget {
  final String label;

  const DarkThemeRow({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Row(
            children: [
              // Icon
              Icon(
                Icons.nightlight_round_rounded,
                size: 16.sp,
                color: theme.colorScheme.onSurface,
              ),
              SizedBox(width: 10.w),

              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),

              // Switch
              Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color.fromARGB(255, 75, 87, 255),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
