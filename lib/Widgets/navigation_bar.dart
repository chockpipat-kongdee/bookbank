// ────────── Package Imports ──────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ────────── Widgets ──────────
import 'package:bookbank/features/home/home_screen.dart';
import 'package:bookbank/features/add_transaction/add_transaction_screen.dart';
import 'package:bookbank/features/charts/chart_screen.dart';
import 'package:bookbank/features/records/record_screen.dart';
import 'package:bookbank/features/notebook/noteBook_screen.dart';

// ────────── Stateful Widget ──────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ────────── State Management ──────────
class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  Key _homeKey = UniqueKey();
  Key _recordKey = UniqueKey();

  // Pages to navigate
  List<Widget> get pages => [
    HomeScreen(key: _homeKey),
    RecordScreen(key: _recordKey),
    const AddTransactionScreen(),
    ChartScreen(),
    NoteBookScreen(),
  ];

  // ────────── Build navigation item ──────────
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },

      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50.w,
        height: 50.h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active indicator
            if (isSelected) ... [
              Container(
                width: 40.w,
                height: 1.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ],
            SizedBox(height: 8.h),

            // Icons
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              size: 23.sp,
            ),

            // label
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────── Build the navigation bar ──────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 80.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Black bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceBright,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14.r),
                      topRight: Radius.circular(14.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, 'Home'),
                      _buildNavItem(1, Icons.list_alt_rounded, 'Records'),
                      SizedBox(width: 50.w),
                      _buildNavItem(3, Icons.area_chart_rounded, 'Charts'),
                      _buildNavItem(4, Icons.edit_square, 'Notes'),
                    ],
                  ),
                ),
              ),

              // ────────── Center button ──────────
              Positioned(
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    showAddItemBottomSheet(
                      context,
                      onSaved: () {
                        setState(() {
                          _homeKey = UniqueKey();
                          _recordKey = UniqueKey();
                        });
                      },
                    );
                  },

                  child: Container(
                    height: 70.h,
                    width: 70.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surfaceBright,
                        width: 10,
                      ),
                    ),

                    child: Icon(
                      Icons.add,
                      color: theme.colorScheme.surfaceBright,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
