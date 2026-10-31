// ────────── Package Imports ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ────────── Local Imports ──────────
import 'package:bookbank/core/theme/app_theme.dart';

// ────────── Menu Row Widget ──────────
class MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const MenuRow({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);

        return Row(
          children: [
            // Icon
            Icon(icon, size: 16.sp, color: theme.colorScheme.onSurface),
            SizedBox(width: 10.w),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        );
      },
    );
  }
}
