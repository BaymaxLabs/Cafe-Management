enum OrderStatus { breached, urgent, onTrack, unassigned }

enum OrderType { dineIn, takeaway }

class OrderItem {
  const OrderItem({required this.name});
  final String name;
}

class Order {
  const Order({
    required this.id,
    required this.table,
    required this.type,
    required this.items,
    required this.status,
    required this.elapsedMinutes,
    required this.slaMinutes,
    this.assignedStaff,
  });

  final String id;
  final String table;
  final OrderType type;
  final List<OrderItem> items;
  final OrderStatus status;
  final int elapsedMinutes;
  final int slaMinutes;
  final String? assignedStaff;

  int get slaRemainingMinutes => slaMinutes - elapsedMinutes;
  double get slaProgress => (elapsedMinutes / slaMinutes).clamp(0.0, 1.0);

  String get typeLabel => type == OrderType.dineIn ? 'Dine-in' : 'Takeaway';
  String get itemsLabel => items.map((i) => i.name).join(' · ');
}
