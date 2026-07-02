import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SiteNav — top app bar + bottom navigation bar
// 6 tabs: Home · Learn · Mentor · Forest · Upper Room · Missions
// ─────────────────────────────────────────────────────────────────────────────

enum NavDestination {
  home,
  learn,
  mentor,
  forest,
  upperRoom,
  missions,
}

class NavItem {
  final String label;
  final IconData icon;
  final NavDestination destination;
  const NavItem(this.label, this.icon, this.destination);
}

const _kNavItems = [
  NavItem('Home',       Icons.home_outlined,              NavDestination.home),
  NavItem('Learn',      Icons.menu_book_outlined,         NavDestination.learn),
  NavItem('Mentor',     Icons.people_outlined,            NavDestination.mentor),
  NavItem('Forest',     Icons.park_outlined,              NavDestination.forest),
  NavItem('Upper Room', Icons.whatshot_outlined,          NavDestination.upperRoom),
  NavItem('Missions',   Icons.flag_outlined,              NavDestination.missions),
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
              // P2P Official Logo
              ClipOval(
                child: Image.network(
                  'https://omkqkasniakcnmfcwrvs.supabase.co/storage/v1/object/public/P2P%20Official%20Logo/P2P%20Official%20Logo.png',
                  width: 28.r,
                  height: 28.r,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.menu_book_outlined,
                        color: AppColors.lightGreen, size: 16.sp),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'P2P Global Bible Study',
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
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 8.w : 6.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.lightGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 16.sp,
                color: isActive
                    ? AppColors.navBg
                    : AppColors.lightGreen.withOpacity(0.80),
              ),
              if (isActive) ...[
                SizedBox(width: 4.w),
                Text(
                  item.label,
                  style: TextStyle(
                    color: AppColors.navBg,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
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
      // Runtime guard: pages list must stay in sync with NavDestination enum.
      : assert(pages.length == 6);

  @override
  State<VineBranchesShell> createState() => _VineBranchesShellState();
}

class _VineBranchesShellState extends State<VineBranchesShell> {
  NavDestination _current = NavDestination.home;

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
