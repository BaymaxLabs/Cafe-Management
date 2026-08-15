import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum BrewNavTab { orders, ops, menu, analytics, settings }

class BrewBottomNav extends StatelessWidget {
  const BrewBottomNav({
    super.key,
    required this.currentTab,
    this.unreadTabs = const {},
    required this.onTabSelected,
  });

  final BrewNavTab currentTab;
  final Set<BrewNavTab> unreadTabs;
  final ValueChanged<BrewNavTab> onTabSelected;

  static const _tabs = [
    _NavTabData(
      tab: BrewNavTab.orders,
      label: 'Orders',
      icon: Icons.grid_view_rounded,
    ),
    _NavTabData(tab: BrewNavTab.ops, label: 'Ops', icon: Icons.tune_rounded),
    _NavTabData(
      tab: BrewNavTab.menu,
      label: 'Menu',
      icon: Icons.menu_book_rounded,
    ),
    _NavTabData(
      tab: BrewNavTab.analytics,
      label: 'Analytics',
      icon: Icons.show_chart_rounded,
    ),
    _NavTabData(
      tab: BrewNavTab.settings,
      label: 'Settings',
      icon: Icons.settings_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(children: _tabs.map((data) => _buildTab(data)).toList()),
        ),
      ),
    );
  }

  Widget _buildTab(_NavTabData data) {
    final isSelected = currentTab == data.tab;
    final hasUnread = unreadTabs.contains(data.tab) && !isSelected;
    final color = isSelected ? AppColors.gold : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelected(data.tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isSelected ? 36 : 0,
              decoration: const BoxDecoration(
                color: Color(0xFF43A047),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
              ),
            ),
            const SizedBox(height: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(data.icon, color: color, size: 22),
                if (hasUnread)
                  Positioned(
                    top: -3,
                    right: -4,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              data.label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTabData {
  const _NavTabData({
    required this.tab,
    required this.label,
    required this.icon,
  });

  final BrewNavTab tab;
  final String label;
  final IconData icon;
}
