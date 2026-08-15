import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/brew_bottom_nav.dart';
import '../models/order.dart';
import '../widgets/order_card.dart';

// Placeholder data until real state/service layer is wired up
final _mockOrders = [
  const Order(
    id: 'ORD-041',
    table: 'T4',
    type: OrderType.dineIn,
    items: [
      OrderItem(name: 'Cappuccino'),
      OrderItem(name: 'Croissant'),
    ],
    status: OrderStatus.breached,
    elapsedMinutes: 22,
    slaMinutes: 15,
    assignedStaff: 'Arun K.',
  ),
  const Order(
    id: 'ORD-039',
    table: 'T1',
    type: OrderType.dineIn,
    items: [
      OrderItem(name: 'Latte'),
      OrderItem(name: 'Avocado Toast'),
      OrderItem(name: 'OJ'),
    ],
    status: OrderStatus.breached,
    elapsedMinutes: 18,
    slaMinutes: 15,
    assignedStaff: null,
  ),
  const Order(
    id: 'ORD-043',
    table: 'T7',
    type: OrderType.dineIn,
    items: [
      OrderItem(name: 'Flat White'),
      OrderItem(name: 'Banana Bread'),
    ],
    status: OrderStatus.urgent,
    elapsedMinutes: 12,
    slaMinutes: 15,
    assignedStaff: 'Priya S.',
  ),
  const Order(
    id: 'ORD-044',
    table: 'TA',
    type: OrderType.takeaway,
    items: [
      OrderItem(name: 'Espresso ×2'),
      OrderItem(name: 'Blueberry Muffin'),
    ],
    status: OrderStatus.urgent,
    elapsedMinutes: 10,
    slaMinutes: 15,
    assignedStaff: 'Arun K.',
  ),
  const Order(
    id: 'ORD-040',
    table: 'T2',
    type: OrderType.dineIn,
    items: [
      OrderItem(name: 'Americano'),
      OrderItem(name: 'Eggs Benedict'),
    ],
    status: OrderStatus.onTrack,
    elapsedMinutes: 5,
    slaMinutes: 15,
    assignedStaff: 'Priya S.',
  ),
  const Order(
    id: 'ORD-045',
    table: 'T3',
    type: OrderType.dineIn,
    items: [OrderItem(name: 'Chai Latte')],
    status: OrderStatus.unassigned,
    elapsedMinutes: 3,
    slaMinutes: 15,
    assignedStaff: null,
  ),
];

enum _FilterTab { all, breached, urgent, onTrack, unassigned }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.userDetails});

  final Map<String, dynamic> userDetails;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  _FilterTab _filter = _FilterTab.all;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _shopName =>
      widget.userDetails['cafeName'] as String? ?? 'Brew Co.';
  String get _shopCode => widget.userDetails['shopCode'] as String? ?? 'T001';
  String get _userName => widget.userDetails['cafeName'] as String? ?? 'Staff';
  String get _userRole => 'Staff';
  String get _userInitial =>
      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'S';

  List<Order> get _filteredOrders {
    var orders = _mockOrders.where((o) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return o.id.toLowerCase().contains(q) ||
            o.table.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    switch (_filter) {
      case _FilterTab.all:
        break;
      case _FilterTab.breached:
        orders = orders.where((o) => o.status == OrderStatus.breached).toList();
      case _FilterTab.urgent:
        orders = orders.where((o) => o.status == OrderStatus.urgent).toList();
      case _FilterTab.onTrack:
        orders = orders.where((o) => o.status == OrderStatus.onTrack).toList();
      case _FilterTab.unassigned:
        orders = orders.where((o) => o.assignedStaff == null).toList();
    }
    return orders;
  }

  int _countFor(_FilterTab tab) {
    switch (tab) {
      case _FilterTab.all:
        return _mockOrders.length;
      case _FilterTab.breached:
        return _mockOrders
            .where((o) => o.status == OrderStatus.breached)
            .length;
      case _FilterTab.urgent:
        return _mockOrders.where((o) => o.status == OrderStatus.urgent).length;
      case _FilterTab.onTrack:
        return _mockOrders.where((o) => o.status == OrderStatus.onTrack).length;
      case _FilterTab.unassigned:
        return _mockOrders.where((o) => o.assignedStaff == null).length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentTab: BrewNavTab.orders,
      title: 'Orders',
      shopName: _shopName,
      shopCode: _shopCode,
      userName: _userName,
      userRole: _userRole,
      userInitial: _userInitial,
      notificationCount: 3,
      unreadTabs: const {BrewNavTab.analytics},
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _SearchBar(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const SizedBox(height: 12),
        _FilterChips(
          selected: _filter,
          countFor: _countFor,
          onSelected: (tab) => setState(() => _filter = tab),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Swipe right or hold to mark complete',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _filteredOrders.length,
            itemBuilder: (_, i) => OrderCard(order: _filteredOrders[i]),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.white, fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search by order ID or table...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.countFor,
    required this.onSelected,
  });

  final _FilterTab selected;
  final int Function(_FilterTab) countFor;
  final ValueChanged<_FilterTab> onSelected;

  static const _tabs = [
    _FilterTab.all,
    _FilterTab.breached,
    _FilterTab.urgent,
    _FilterTab.onTrack,
    _FilterTab.unassigned,
  ];

  String _label(_FilterTab tab) {
    switch (tab) {
      case _FilterTab.all:
        return 'All';
      case _FilterTab.breached:
        return 'Breached';
      case _FilterTab.urgent:
        return 'Urgent';
      case _FilterTab.onTrack:
        return 'On Track';
      case _FilterTab.unassigned:
        return 'Unassigned';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _tabs.map((tab) {
          final isSelected = selected == tab;
          return GestureDetector(
            onTap: () => onSelected(tab),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.white : const Color(0xFF2A2A2A),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _label(tab),
                    style: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${countFor(tab)}',
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textMuted
                          : const Color(0xFF555555),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
