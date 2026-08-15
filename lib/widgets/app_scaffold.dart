import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'brew_app_bar.dart';
import 'brew_bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.currentTab,
    required this.title,
    required this.shopName,
    required this.shopCode,
    required this.userInitial,
    required this.userName,
    required this.userRole,
    required this.body,
    this.notificationCount = 0,
    this.unreadTabs = const {},
    this.onNotificationTap,
    this.onTabSelected,
  });

  final BrewNavTab currentTab;
  final String title;
  final String shopName;
  final String shopCode;
  final String userInitial;
  final String userName;
  final String userRole;
  final Widget body;
  final int notificationCount;
  final Set<BrewNavTab> unreadTabs;
  final VoidCallback? onNotificationTap;
  final ValueChanged<BrewNavTab>? onTabSelected;

  static const double _sidebarWidth = 200;
  static const double _breakpoint = 800;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _breakpoint;
    return isWide ? _wide(context) : _narrow(context);
  }

  Widget _wide(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          SizedBox(
            width: _sidebarWidth,
            child: _Sidebar(
              currentTab: currentTab,
              shopName: shopName,
              shopCode: shopCode,
              userInitial: userInitial,
              userName: userName,
              userRole: userRole,
              notificationCount: notificationCount,
              unreadTabs: unreadTabs,
              onTabSelected: onTabSelected,
              onNotificationTap: onNotificationTap,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WideHeader(
                  title: title,
                  subtitle: _subtitleFor(currentTab),
                  notificationCount: notificationCount,
                  onNotificationTap: onNotificationTap,
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _narrow(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrewAppBar(
        title: title,
        shopName: shopName,
        shopCode: shopCode,
        notificationCount: notificationCount,
        onNotificationTap: onNotificationTap,
      ),
      body: body,
      bottomNavigationBar: BrewBottomNav(
        currentTab: currentTab,
        unreadTabs: unreadTabs,
        onTabSelected: onTabSelected ?? (_) {},
      ),
    );
  }

  String _subtitleFor(BrewNavTab tab) {
    switch (tab) {
      case BrewNavTab.orders:
        return 'Live order board with SLA tracking';
      case BrewNavTab.ops:
        return 'Inventory, staff, and operations';
      case BrewNavTab.menu:
        return 'Menu catalogue and stock';
      case BrewNavTab.analytics:
        return 'Sales and performance insights';
      case BrewNavTab.settings:
        return 'App and account settings';
    }
  }
}

class _WideHeader extends StatelessWidget {
  const _WideHeader({
    required this.title,
    required this.subtitle,
    required this.notificationCount,
    this.onNotificationTap,
  });

  final String title;
  final String subtitle;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                  size: 26,
                ),
                if (notificationCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          notificationCount > 9 ? '9+' : '$notificationCount',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.currentTab,
    required this.shopName,
    required this.shopCode,
    required this.userInitial,
    required this.userName,
    required this.userRole,
    required this.notificationCount,
    required this.unreadTabs,
    this.onTabSelected,
    this.onNotificationTap,
  });

  final BrewNavTab currentTab;
  final String shopName;
  final String shopCode;
  final String userInitial;
  final String userName;
  final String userRole;
  final int notificationCount;
  final Set<BrewNavTab> unreadTabs;
  final ValueChanged<BrewNavTab>? onTabSelected;
  final VoidCallback? onNotificationTap;

  static const _navItems = [
    _SidebarItem(
      tab: BrewNavTab.orders,
      label: 'Orders',
      icon: Icons.grid_view_rounded,
    ),
    _SidebarItem(
      tab: BrewNavTab.ops,
      label: 'Operations',
      icon: Icons.tune_rounded,
    ),
    _SidebarItem(
      tab: BrewNavTab.menu,
      label: 'Menu',
      icon: Icons.menu_book_rounded,
    ),
    _SidebarItem(
      tab: BrewNavTab.analytics,
      label: 'Analytics',
      icon: Icons.show_chart_rounded,
      isPro: true,
    ),
    _SidebarItem(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + shop info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.coffee_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopName,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          shopCode,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'NAVIGATION',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...(_navItems.map(
              (item) => _SidebarNavItem(
                item: item,
                isSelected: currentTab == item.tab,
                hasUnread:
                    unreadTabs.contains(item.tab) && currentTab != item.tab,
                onTap: () => onTabSelected?.call(item.tab),
              ),
            )),
            const Spacer(),
            // User info at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userRole,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.item,
    required this.isSelected,
    required this.hasUnread,
    required this.onTap,
  });

  final _SidebarItem item;
  final bool isSelected;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.gold : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isSelected ? AppColors.gold : AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (item.isPro)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            if (hasUnread && !item.isPro)
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem {
  const _SidebarItem({
    required this.tab,
    required this.label,
    required this.icon,
    this.isPro = false,
  });

  final BrewNavTab tab;
  final String label;
  final IconData icon;
  final bool isPro;
}
