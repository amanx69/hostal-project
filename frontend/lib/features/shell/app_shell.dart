import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNav(navigationShell: navigationShell),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _BottomNav({required this.navigationShell});

  // 4 tabs: Home | Search | Create | Profile
  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.search_rounded,
      activeIcon: Icons.search_rounded,
      label: 'Search',
    ),
    _NavItem(
      icon: Icons.add_box_outlined,
      activeIcon: Icons.add_box_rounded,
      label: 'Post',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Me',
    ),
  ];

  void _onTap(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = navigationShell.currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = current == i;
              final isCreate = i == 2; // "Post" tab

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onTap(i),
                  child: _NavTab(
                    item: item,
                    isActive: isActive,
                    isCreate: isCreate,
                    isDark: isDark,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Individual Tab ───────────────────────────────────────────────────────────

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool isCreate;
  final bool isDark;

  const _NavTab({
    required this.item,
    required this.isActive,
    required this.isCreate,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (isCreate) {
      return Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.brandGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isActive ? item.activeIcon : item.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }

    // Regular tab — icon + animated indicator dot
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: child,
          ),
          child: Icon(
            isActive ? item.activeIcon : item.icon,
            key: ValueKey('${item.label}-$isActive'),
            color: isActive
                ? AppColors.primary
                : (isDark
                    ? const Color(0xFF6B5055)
                    : const Color(0xFFBFA0A6)),
            size: 26,
          ),
        ),
        const SizedBox(height: 4),
        // Indicator dot
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 16 : 0,
          height: 3,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(colors: AppColors.brandGradient)
                : null,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─── Nav Item Data ────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
