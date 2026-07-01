import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SiteNav — mirrors site-nav.tsx
// Top app bar (header) + bottom navigation bar for mobile.
// ─────────────────────────────────────────────────────────────────────────────

enum NavDestination {
  journey,
  globalForest,
  peerSession,
  upperRoom,
}

class NavItem {
  final String label;
  final IconData icon;
  final NavDestination destination;
  const NavItem(this.label, this.icon, this.destination);
}

const _kNavItems = [
  NavItem('Journey', Icons.spa_outlined, NavDestination.journey),
  NavItem('Global Forest', Icons.public_outlined, NavDestination.globalForest),
  NavItem('Peer Session', Icons.menu_book_outlined, NavDestination.peerSession),
  NavItem('Upper Room', Icons.local_fire_department_outlined, NavDestination.upperRoom),
];

// ── Top App Bar ───────────────────────────────────────────────────────────────

class VineBranchesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VineBranchesAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBg,
        border: Border(
          bottom: BorderSide(color: AppColors.navBorder, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              // Logo mark
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentGreen.withOpacity(0.40),
                  ),
                ),
                child: Icon(
                  Icons.spa_outlined,
                  color: AppColors.lightGreen,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Vine & Branches',
                style: TextStyle(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────────────────────

class VineBranchesBottomNav extends StatelessWidget {
  final NavDestination current;
  final ValueChanged<NavDestination> onTap;

  const VineBranchesBottomNav({
    super.key,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBg,
        border: Border(
          top: BorderSide(color: AppColors.navBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _kNavItems.map((item) {
              final isActive = item.destination == current;
              return _NavPill(
                item: item,
                isActive: isActive,
                onTap: () => onTap(item.destination),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavPill({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: item.label,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.lightGreen
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 16.sp,
                color: isActive ? AppColors.navBg : AppColors.lightGreen.withOpacity(0.80),
              ),
              if (isActive) ...[
                SizedBox(width: 5.w),
                Text(
                  item.label,
                  style: TextStyle(
                    color: AppColors.navBg,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shell scaffold ────────────────────────────────────────────────────────────

/// Drop-in shell that provides the sticky header + bottom nav.
/// Supply [pages] in the same order as [NavDestination].
class VineBranchesShell extends StatefulWidget {
  final List<Widget> pages;

  const VineBranchesShell({super.key, required this.pages})
      : assert(pages.length == 4, 'Provide exactly 4 pages (one per NavDestination)');

  @override
  State<VineBranchesShell> createState() => _VineBranchesShellState();
}

class _VineBranchesShellState extends State<VineBranchesShell> {
  NavDestination _current = NavDestination.journey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VineBranchesAppBar(),
      body: IndexedStack(
        index: _current.index,
        children: widget.pages,
      ),
      bottomNavigationBar: VineBranchesBottomNav(
        current: _current,
        onTap: (d) => setState(() => _current = d),
      ),
    );
  }
}
